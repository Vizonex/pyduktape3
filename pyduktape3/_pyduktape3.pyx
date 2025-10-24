# cython: language_level = 3, freethreading_compatible = True
# distutils: sources = 'pyduktape3/duktape.c'

from .duktape cimport *
import contextlib
import os
import traceback
from cpython.unicode cimport PyUnicode_Check, PyUnicode_AsUTF8
from cpython.exc cimport PyErr_SetNone, PyErr_SetString
from cpython.bytes cimport PyBytes_GET_SIZE, PyBytes_AS_STRING
from cpython.mem cimport PyMem_Free, PyMem_Realloc, PyMem_Malloc


# TODO: (Vizonex) Planned to move some of these APIs to a cython __init__.pxd for further use in Cython...

cdef extern from "Python.h":
    unsigned long PyThread_get_thread_ident()

# TODO: Public exposure while dissallowing external editing
DUK_TYPE_NONE = 0
DUK_TYPE_UNDEFINED = 1
DUK_TYPE_NULL = 2
DUK_TYPE_BOOLEAN = 3
DUK_TYPE_NUMBER = 4
DUK_TYPE_STRING = 5
DUK_TYPE_OBJECT = 6
DUK_TYPE_BUFFER = 7
DUK_TYPE_POINTER = 8
DUK_TYPE_LIGHTFUNC = 9
DUK_ENUM_OWN_PROPERTIES_ONLY = (1 << 2)
DUK_VARARGS = -1
DUK_ERR_ERROR = 100


# NOTE: It's better that these be C-Extensions for increased performance reasons...
cdef class DuktapeError(Exception):
    pass

cdef class DuktapeFatalError(Exception):
    pass

cdef class DuktapeThreadError(DuktapeError):
    pass


cdef class JSError(Exception):
    pass

# New in duktape 3.0 alloc functions

cdef void* pyduk_malloc(
    void* udata,
    duk_size_t size
) noexcept:
    return PyMem_Malloc(size)

cdef void* pyduk_realloc(
    void* udata,
    void* ptr,
    duk_size_t size
) noexcept:
    return PyMem_Realloc(ptr, size)

cdef void pyduk_free(
    void* udata,
    void* ptr
) noexcept:
    PyMem_Free(ptr)

# Probably the best way to handle such an occurance...
# TODO: Fatal handler?
cdef void pyduk_fatal_function(void* udata, const char* msg) noexcept:
    PyErr_SetString(DuktapeFatalError, <char*>msg)




cdef class DuktapeContext(object):
    cdef duk_context *ctx
    
    cdef object js_base_path
    # index into the global js stash
    # when a js value is returned to python,
    # a reference is kept in the global stash
    # to avoid garbage collection
    cdef int next_ref_index

    # these keep python objects referenced only by js code alive
    cdef dict registered_objects
    cdef dict registered_proxies
    cdef dict registered_proxies_reverse

    # Thread id
    cdef unsigned long thread_id

    def __cinit__(self):
        self.thread_id = PyThread_get_thread_ident()
        self.js_base_path = ''
        self.next_ref_index = -1

        self.registered_objects = {}
        self.registered_proxies = {}
        self.registered_proxies_reverse = {}

        self.ctx = duk_create_heap(pyduk_malloc, pyduk_realloc, pyduk_free, <void*>self, pyduk_fatal_function)
        if self.ctx == NULL:
            # TODO: raise MemoryError instead...
            raise DuktapeError('Can\'t allocate context')

        set_python_context(self.ctx, self)
        # duk_print_alert_init(self.ctx, 0)
        self._setup_module_search_function()

    cdef void _setup_module_search_function(self):
        duk_get_global_string(self.ctx, b"Duktape")
        duk_push_c_function(self.ctx, module_search, 1)
        duk_put_prop_string(self.ctx, -2, b"modSearch")
        duk_pop(self.ctx)

    # Nitpick, this should be internal and not public...
    cdef inline int _check_thread(self):
        if PyThread_get_thread_ident() != self.thread_id:
            PyErr_SetNone(DuktapeThreadError)
            return -1
        return 0

    def set_globals(self, **kwargs):
        if self._check_thread() < 0:
            raise

        for name, value in kwargs.items():
            self._set_global(name.encode(), value)

    cdef void _set_global(self, const char *name, object value) except *:
        to_js(self.ctx, value)
        duk_put_global_string(self.ctx, name)

    def get_global(self, name):
        if not PyUnicode_Check(name):
            raise TypeError('Global variable name must be a string, {} found'.format(type(name)))

        duk_get_global_string(self.ctx, name.encode())
        try:
            value = to_python(self, -1)
        finally:
            duk_pop(self.ctx)

        return value

    def set_base_path(self, path):
        if not PyUnicode_Check(path):
            raise TypeError('Path must be a string, {} found'.format(type(path)))

        self.js_base_path = path

    def eval_js(self, src):
        if isinstance(src, str):
            src = src.encode()

        if not isinstance(src, bytes):
            raise TypeError('Javascript source must be a string or bytes object')

        return self._eval_js(src)

    def eval_js_file(self, src_path):
        src_path = str(src_path)
        with open(self.get_file_path(src_path), 'rb') as f:
            code = f.read()

        return self._eval_js(code)

    def get_file_path(self, src_path):
        if not src_path.endswith('.js'):
            src_path = '{}.js'.format(src_path)

        if not os.path.isabs(src_path):
            src_path = os.path.join(self.js_base_path, src_path)

        return src_path

    cdef object _eval_js(self, bytes src):
        if self._check_thread() < 0:
            raise

        if duk_eval_raw(self.ctx, PyBytes_AS_STRING(src), PyBytes_GET_SIZE(src), 8) != 0: # DUK_COMPILE_EVAL
            error = self.get_error()
            duk_pop(self.ctx)
            result = None
        else:
            error = None
            result = to_python(self, -1)
        duk_pop(self.ctx)

        if error:
            raise JSError(error)

        return result

    cdef object get_error(self):
        if duk_get_prop_string(self.ctx, -1, b'stack') == 0:
            error = duk_safe_to_lstring(self.ctx, -2, NULL).decode()
        else:
            error = to_python(self, -1)

        return error

    cpdef JSRef make_jsref(self, duk_idx_t index):
        if self._check_thread() < 0:
            raise

        assert duk_is_object(self.ctx, index)

        self.next_ref_index += 1

        duk_push_global_stash(self.ctx)
        duk_dup(self.ctx, index - 1)
        duk_put_prop_index(self.ctx, -2, self.next_ref_index)
        duk_pop(self.ctx)

        return JSRef(self, self.next_ref_index)

    cdef void register_object(self, void *proxy_ptr, object py_obj):
        self.registered_objects[<unsigned long>proxy_ptr] = py_obj

    cdef object get_registered_object(self, void *proxy_ptr):
        return self.registered_objects[<unsigned long>proxy_ptr]

    cdef int is_registered_object(self, void *proxy_ptr):
        return <unsigned long>proxy_ptr in self.registered_objects

    cdef void unregister_object(self, void *proxy_ptr):
        del self.registered_objects[<unsigned long>proxy_ptr]

    cdef void register_proxy(self, void *proxy_ptr, void *target_ptr, object py_obj):
        self.registered_proxies[<unsigned long>proxy_ptr] = <unsigned long>target_ptr
        self.registered_proxies_reverse[<unsigned long>target_ptr] = <unsigned long>proxy_ptr
        self.register_object(target_ptr, py_obj)

    cdef object get_registered_object_from_proxy(self, void *proxy_ptr):
        return self.registered_objects[self.registered_proxies[<unsigned long>proxy_ptr]]

    cdef int is_registered_proxy(self, void *proxy_ptr):
        if <unsigned long>proxy_ptr not in self.registered_proxies:
            return 0

        return self.registered_proxies[<unsigned long>proxy_ptr] in self.registered_objects

    cdef void unregister_proxy_from_target(self, void *target_ptr):
        proxy_ptr = self.registered_proxies_reverse.pop(<unsigned long>target_ptr)
        del self.registered_objects[<unsigned long>target_ptr]
        del self.registered_proxies[proxy_ptr]

    def __dealloc__(self):
        duk_destroy_heap(self.ctx)


cdef void set_python_context(duk_context *ctx, DuktapeContext py_ctx):
    duk_push_global_stash(ctx)
    duk_push_pointer(ctx, <void*>py_ctx)
    duk_put_prop_string(ctx, -2, b"__py_ctx")
    duk_pop(ctx)


cdef DuktapeContext get_python_context(duk_context *ctx):
    duk_push_global_stash(ctx)
    duk_get_prop_string(ctx, -1, b"__py_ctx")
    py_ctx = <DuktapeContext>duk_get_pointer(ctx, -1)
    duk_pop_2(ctx)

    assert py_ctx.ctx is ctx

    return py_ctx


cdef class JSRef(object):
    cdef DuktapeContext py_ctx
    cdef int ref_index

    def __init__(self, DuktapeContext py_ctx, int ref_index):
        py_ctx._check_thread()

        self.py_ctx = py_ctx
        self.ref_index = ref_index

    cpdef to_js(self):
        if self.py_ctx._check_thread() < 0:
            raise

        duk_push_global_stash(self.py_ctx.ctx)
        if duk_get_prop_index(self.py_ctx.ctx, -1, self.ref_index) == 0:
            duk_pop_2(self.py_ctx.ctx)
            raise DuktapeError('Invalid reference')
        duk_swap(self.py_ctx.ctx, -1, -2)
        duk_pop(self.py_ctx.ctx)

    def __del__(self):
        duk_push_global_stash(self.py_ctx.ctx)
        if not duk_has_prop_index(self.py_ctx.ctx, -1, self.ref_index):
            duk_pop(self.py_ctx.ctx)
            raise DuktapeError('Trying to delete non-existent reference')

        duk_del_prop_index(self.py_ctx.ctx, -1, self.ref_index)
        duk_pop(self.py_ctx.ctx)


ctypedef duk_ret_t (*callfunc)(duk_context *, duk_idx_t) 


cdef class JSProxy(object):
    cdef JSRef __ref
    cdef object __bind_proxy

    def __init__(self, JSRef ref, object bind_proxy):
        ref.py_ctx._check_thread()

        self.__ref = ref
        self.__bind_proxy = bind_proxy

    def __setattr__(self, name, value):
        self.__ref.py_ctx._check_thread()

        ctx = self.__ref.py_ctx.ctx

        self.__ref.to_js()
        to_js(ctx, value)
        duk_put_prop_string(ctx, -2, name)
        duk_pop(ctx)

    def __getattr__(self, name):
        self.__ref.py_ctx._check_thread()

        ctx = self.__ref.py_ctx.ctx

        self.__ref.to_js()
        if not duk_get_prop_string(ctx, -1, name.encode()):
            duk_pop_2(ctx)
            raise AttributeError('Attribute {} missing'.format(name))

        try:
            res = to_python(self.__ref.py_ctx, -1, self)
        finally:
            duk_pop_2(ctx)

        return res

    def __getitem__(self, object name):
        self.__ref.py_ctx._check_thread()

        if not isinstance(name, (int, str)):
            raise TypeError('{} is not a valid index'.format(name))

        return getattr(self, str(name))

    def __repr__(self):
        cdef duk_context* ctx
        if self.__ref.py_ctx._check_thread() < 0:
            raise

        ctx = self.__ref.py_ctx.ctx

        self.__ref.to_js()
        res = <bytes>duk_safe_to_lstring(ctx, -1, NULL)
        duk_pop(ctx)

        return '<JSProxy: {}, bind_proxy={}>'.format(res.decode(), self.__bind_proxy.__repr__())

    def __call__(self, *args):
        if self.__ref.py_ctx._check_thread() < 0:
            raise

        if self.__bind_proxy is None:
            return self.__call(duk_pcall, args, None)
        else:
            return self.__call(duk_pcall_method, args, self.__bind_proxy)

    def new(self, *args):
        if self.__ref.py_ctx._check_thread() < 0:
            raise 

        return self.__call(safe_new, args, None)

    cdef object __call(self, callfunc call_type, tuple args, this):
        cdef object arg

        if self.__ref.py_ctx._check_thread() < 0:
            raise
        
        ctx = self.__ref.py_ctx.ctx

        self.__ref.to_js()

        if not duk_is_function(ctx, -1):
            duk_pop(ctx)
            raise TypeError('Can\'t call')

        if this is not None:
            to_js(ctx, this)

        for arg in args:
            to_js(ctx, arg)

        if call_type(ctx, len(args)) == 0:
            res, error = to_python(self.__ref.py_ctx, -1), None
        else:
            res, error = None, self.__ref.py_ctx.get_error()

        duk_pop(ctx)

        if error is not None:
            raise JSError(error)

        return res

    # XXX: __nonzero__ removed in Python 3...
    def __bool__(self):
        if self.__ref.py_ctx._check_thread() < 0:
            raise

        return getattr(self, 'length', 1) > 0

    def __len__(self):
        if self.__ref.py_ctx._check_thread() < 0:
            raise
        return self.length

    def __iter__(self):
        if self.__ref.py_ctx._check_thread() < 0:
            raise
        ctx = self.__ref.py_ctx.ctx

        self.__ref.to_js()
        is_array = duk_is_array(ctx, -1)
        is_object = duk_is_object(ctx, -1)

        if is_array:
            duk_pop(ctx)
            for i in range(0, self.length):
                yield self[i]
        elif is_object:
            duk_enum(ctx, -1, DUK_ENUM_OWN_PROPERTIES_ONLY)

            keys = []
            while duk_next(ctx, -1, 0) != 0:
                keys.append(get_python_string(ctx, -1))
                duk_pop(ctx)
            duk_pop_2(ctx) # pop enumerator and self.__ref

            for key in keys:
                yield key

    cpdef object to_js(self):
        if self.__ref.py_ctx._check_thread() < 0:
            raise
        self.__ref.to_js()


cdef duk_ret_t call_new(duk_context *ctx, void *udata) noexcept:
    # [ constructor arg1 arg2 ... argn nargs ]
    nargs = duk_require_int(ctx, -1)
    duk_pop(ctx)
    duk_new(ctx, nargs)
    duk_push_undefined(ctx) # replace the popped argument
    duk_swap(ctx, -1 , -2)

    return 1


cdef duk_ret_t safe_new(duk_context *ctx, int nargs):
    # [ constructor arg1 arg2 ... argn nargs ]
    duk_push_int(ctx, nargs)
    return duk_safe_call(ctx, call_new, NULL, nargs + 2, 1)


cdef duk_ret_t module_search(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)
    module_id = duk_require_string(ctx, -1)

    try:
        with open(py_ctx.get_file_path(module_id.decode()), 'rb') as module:
            source = module.read()
    except:
        duk_error(ctx, DUK_ERR_ERROR, ('Could not load module: %s' % module_id.decode('utf-8')).encode('utf-8'))

    duk_push_string(ctx, source)

    return 1


cdef object to_python(DuktapeContext py_ctx, duk_idx_t index, JSProxy bind_proxy=None):
    cdef duk_context *ctx = py_ctx.ctx

    type_ = duk_get_type(ctx, index)

    if type_ == DUK_TYPE_NONE:
        raise DuktapeError('Nothing to convert')

    if type_ == DUK_TYPE_BUFFER or type_ == DUK_TYPE_LIGHTFUNC or type_ == DUK_TYPE_POINTER:
        raise DuktapeError('Type cannot be converted')

    if type_ == DUK_TYPE_NULL or type_ == DUK_TYPE_UNDEFINED:
        return None

    if type_ == DUK_TYPE_BOOLEAN:
        return bool(duk_get_boolean(ctx, index))

    if type_ == DUK_TYPE_NUMBER:
        value = float(duk_get_number(ctx, index))
        if value.is_integer():
            return int(value)
        else:
            return value

    if type_ == DUK_TYPE_STRING:
        return get_python_string(ctx, index)

    if type_ == DUK_TYPE_OBJECT:
        value_ptr = duk_get_heapptr(ctx, index)
        if py_ctx.is_registered_proxy(value_ptr):
            return py_ctx.get_registered_object_from_proxy(value_ptr)
        else:
            return JSProxy(py_ctx.make_jsref(index), bind_proxy)

    assert False


cdef inline object get_python_string(duk_context *ctx, duk_idx_t index):
    return duk_get_string(ctx, index).decode(errors='surrogateescape')

cdef void to_js(duk_context *ctx, object value) except *:
    if value is None:
        duk_push_null(ctx)
        return

    if value is False or value is True:
        duk_push_boolean(ctx, int(value))
        return

    if isinstance(value, int):
        max_positive_js_int = 1 << 53
        min_negative_js_int = -(1 << 53) - 1

        if value >= min_negative_js_int and value <= max_positive_js_int:
            duk_push_number(ctx, float(value))
        else:
            raise OverflowError('Cannot convert {}, number out of range'.format(value))
        return

    if isinstance(value, float):
        duk_push_number(ctx, value)
        return

    if isinstance(value, str):
        duk_push_string(ctx, value.encode())
        return

    if isinstance(value, JSProxy):
        value.to_js()
        return

    if callable(value):
        push_callback(ctx, value)
        return

    push_py_proxy(ctx, value)


cdef void push_py_proxy(duk_context *ctx, object obj) except *:
    py_ctx = get_python_context(ctx)

    duk_get_global_string(ctx, b'Proxy')

    duk_push_object(ctx) # proxy target
    duk_push_c_function(ctx, py_proxy_finalizer, 1)
    duk_set_finalizer(ctx, -2)
    target_ptr = duk_get_heapptr(ctx, -1)

    duk_push_object(ctx) # proxy options

    duk_push_c_function(ctx, py_proxy_get, 3)
    duk_put_prop_string(ctx, -2, b'get')

    duk_push_c_function(ctx, py_proxy_set, 4)
    duk_put_prop_string(ctx, -2, b'set')

    duk_push_c_function(ctx, py_proxy_has, 2)
    duk_put_prop_string(ctx, -2, b'has')

    if safe_new(ctx, 2) != 0:
        error = py_ctx.get_error()
        duk_pop(ctx)
        raise DuktapeError(error)

    proxy_ptr = duk_get_heapptr(ctx, -1)
    py_ctx.register_proxy(proxy_ptr, target_ptr, obj)


cdef duk_ret_t py_proxy_finalizer(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)

    target_ptr = duk_get_heapptr(ctx, -1)
    py_ctx.unregister_proxy_from_target(target_ptr)

    return 0


cdef duk_ret_t py_proxy_get(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)
    n_args = duk_get_top(ctx)

    with wrap_python_exception(py_ctx):
        target = py_ctx.get_registered_object(duk_get_heapptr(ctx, 0 - n_args))
        key = to_python(py_ctx, 1 - n_args)
        value = None

        if isinstance(target, (list, tuple)):
            if key == 'length':
                # special attribute
                value = len(target)
            else:
                # key is always a string,
                # but we need ints to index list and tuples
                try:
                    key = int(key)
                except (TypeError, ValueError):
                    pass

        if value is None:
            try:
                value = target[key]
            except (TypeError, IndexError, KeyError):
                if isinstance(key, str):
                    value = getattr(target, key, None)

        to_js(ctx, value)

    return 1


cdef duk_ret_t py_proxy_has(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)
    n_args = duk_get_top(ctx)

    with wrap_python_exception(py_ctx):
        target = py_ctx.get_registered_object(duk_get_heapptr(ctx, 0 - n_args))
        key = to_python(py_ctx, 1 - n_args)

        if isinstance(target, (list, tuple)):
            try:
                key = int(key)
            except (TypeError, ValueError):
                pass

        try:
            target[key]
            res = True
        except (KeyError, IndexError):
            res = False
        except TypeError:
            res = hasattr(target, key)

        to_js(ctx, res)

    return 1


cdef duk_ret_t py_proxy_set(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)
    n_args = duk_get_top(ctx)

    with wrap_python_exception(py_ctx):
        target = py_ctx.get_registered_object(duk_get_heapptr(ctx, 0 - n_args))
        key = to_python(py_ctx, 1 - n_args)
        value = to_python(py_ctx, 2 - n_args)

        if isinstance(target, (list, tuple)):
            try:
                key = int(key)
            except (TypeError, ValueError):
                pass

        try:
            target[key] = value
        except TypeError:
            setattr(target, key, value)

    duk_push_boolean(ctx, 1)

    return 1


cdef duk_ret_t callback_finalizer(duk_context *ctx) noexcept:
    py_ctx = get_python_context(ctx)
    target_ptr = duk_get_heapptr(ctx, -1)
    py_ctx.unregister_object(target_ptr)

    return 0


cdef void push_callback(duk_context *ctx, object fn) except *:
    assert callable(fn)

    py_ctx = get_python_context(ctx)

    duk_push_c_function(ctx, callback, DUK_VARARGS)

    duk_push_c_function(ctx, callback_finalizer, 1)
    duk_set_finalizer(ctx, -2)

    py_ctx.register_object(duk_get_heapptr(ctx, -1), fn)


cdef duk_ret_t callback(duk_context *ctx) noexcept:
    if duk_is_constructor_call(ctx):
        duk_error(ctx, DUK_ERR_ERROR, b'can\'t use new on python objects')

    py_ctx = get_python_context(ctx)

    n_args = duk_get_top(ctx)

    with wrap_python_exception(py_ctx):
        args = []
        for i in range(0, n_args):
            args.append(to_python(py_ctx, i - n_args))

        duk_push_current_function(ctx)
        python_callback = py_ctx.get_registered_object(duk_get_heapptr(ctx, -1))
        duk_pop(ctx)

        res = python_callback(*args)

        to_js(ctx, res)

    return 1


@contextlib.contextmanager
def wrap_python_exception(DuktapeContext py_ctx):
    try:
        yield
    except:
        error = traceback.format_exc()
        error = error.replace('%', '%%')
        duk_error(py_ctx.ctx, DUK_ERR_ERROR, PyUnicode_AsUTF8(error))