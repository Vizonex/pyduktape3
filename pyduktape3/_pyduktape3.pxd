from cpython.exc cimport PyErr_SetNone
from libc.stdint cimport uint8_t
from libc.stdio cimport FILE, fflush, fprintf, fwrite, stdin, stderr, stdout

cdef extern from "Python.h":
    cdef unsigned long int PyThread_get_thread_ident() noexcept


cdef extern from 'duktape.h':
    ctypedef struct duk_context:
        pass

    ctypedef int duk_errcode_t
    ctypedef int duk_int_t
    ctypedef size_t duk_size_t
    ctypedef duk_int_t duk_idx_t
    ctypedef int duk_bool_t
    ctypedef unsigned int duk_uint_t
    ctypedef unsigned int duk_uarridx_t
    ctypedef double duk_double_t
    ctypedef int duk_ret_t

    ctypedef void* (*duk_alloc_function) (void *udata, duk_size_t size)
    ctypedef void* (*duk_realloc_function) (void *udata, void *ptr, duk_size_t size)
    ctypedef void (*duk_free_function) (void *udata, void *ptr)
    ctypedef void (*duk_fatal_function) (duk_context *ctx, duk_errcode_t code, const char *msg)
    ctypedef duk_ret_t (*duk_c_function)(duk_context *ctx)
    ctypedef duk_ret_t (*duk_safe_call_function) (duk_context *ctx, void *udata)

    cdef duk_context* duk_create_heap(duk_alloc_function alloc_func, duk_realloc_function realloc_func, duk_free_function free_func, void *heap_udata, duk_fatal_function fatal_handler)
    cdef duk_context* duk_create_heap_default()
    cdef void duk_destroy_heap(duk_context *context)
    cdef duk_int_t duk_peval_string(duk_context *context, const char *source)
    cdef const char* duk_safe_to_string(duk_context *ctx, duk_idx_t index)
    cdef void duk_pop(duk_context *ctx)

    cdef duk_bool_t duk_get_boolean(duk_context *ctx, duk_idx_t index)
    cdef const char* duk_get_string(duk_context *ctx, duk_idx_t index)
    cdef double duk_get_number(duk_context *ctx, duk_idx_t index)
    cdef int duk_get_type(duk_context *ctx, duk_idx_t index)
    cdef void duk_enum(duk_context *ctx, duk_idx_t obj_index, duk_uint_t enum_flags)
    cdef duk_bool_t duk_next(duk_context *ctx, duk_idx_t enum_index, duk_bool_t get_value)
    cdef duk_bool_t duk_get_prop_string(duk_context *ctx, duk_idx_t obj_index, const char *key)
    cdef duk_bool_t duk_get_prop_index(duk_context *ctx, duk_idx_t obj_index, duk_uarridx_t arr_index)
    cdef duk_bool_t duk_is_array(duk_context *ctx, duk_idx_t index)
    cdef duk_int_t duk_get_int(duk_context *ctx, duk_idx_t index)
    cdef void duk_push_undefined(duk_context *ctx)
    cdef void duk_push_null(duk_context *ctx)
    cdef void duk_push_boolean(duk_context *ctx, duk_bool_t value)
    cdef duk_bool_t duk_put_prop(duk_context *ctx, duk_idx_t obj_index)
    cdef duk_idx_t duk_push_object(duk_context *ctx)
    cdef duk_bool_t duk_put_prop_index(duk_context *ctx, duk_idx_t obj_index, duk_uarridx_t arr_index)
    cdef duk_idx_t duk_push_array(duk_context *ctx)
    cdef const char *duk_push_string(duk_context *ctx, const char *str)
    cdef void duk_push_number(duk_context *ctx, duk_double_t val)
    cdef void duk_push_int(duk_context *ctx, duk_int_t val)
    cdef duk_bool_t duk_put_global_string(duk_context *ctx, const char *key)
    cdef duk_bool_t duk_get_global_string(duk_context *ctx, const char *key)
    cdef void duk_push_current_function(duk_context *ctx)
    cdef duk_idx_t duk_get_top(duk_context *ctx)
    cdef duk_bool_t duk_put_prop_string(duk_context *ctx, duk_idx_t obj_index, const char *key)
    cdef duk_idx_t duk_push_c_function(duk_context *ctx, duk_c_function func, duk_idx_t nargs)
    cdef duk_bool_t duk_is_constructor_call(duk_context *ctx)
    cdef void duk_pop_2(duk_context *ctx)
    cdef void duk_error(duk_context *ctx, duk_errcode_t err_code, const char *fmt, ...)
    cdef const char *duk_require_string(duk_context *ctx, duk_idx_t index)
    cdef duk_ret_t duk_pcall(duk_context *ctx, duk_idx_t nargs)
    cdef duk_int_t duk_pcall_method(duk_context *ctx, duk_idx_t nargs)
    cdef duk_bool_t duk_is_object(duk_context *ctx, duk_idx_t index)
    cdef void duk_push_global_stash(duk_context *ctx)
    cdef void duk_dup(duk_context *ctx, duk_idx_t from_index)
    cdef duk_bool_t duk_has_prop_index(duk_context *ctx, duk_idx_t obj_index, duk_uarridx_t arr_index)
    cdef duk_bool_t duk_del_prop_index(duk_context *ctx, duk_idx_t obj_index, duk_uarridx_t arr_index)
    cdef duk_bool_t duk_is_callable(duk_context *ctx, duk_idx_t index)
    cdef void duk_push_pointer(duk_context *ctx, void *p)
    cdef void *duk_get_pointer(duk_context *ctx, duk_idx_t index)
    cdef duk_bool_t duk_is_pointer(duk_context *ctx, duk_idx_t index)
    cdef duk_int_t duk_safe_call(duk_context *ctx, duk_safe_call_function func, void *udata, duk_idx_t nargs, duk_idx_t nrets)
    cdef void duk_new(duk_context *ctx, duk_idx_t nargs)
    cdef duk_int_t duk_require_int(duk_context *ctx, duk_idx_t index)
    cdef void duk_swap(duk_context *ctx, duk_idx_t index1, duk_idx_t index2)
    cdef void duk_dump_context_stdout(duk_context *ctx)
    cdef void duk_set_finalizer(duk_context *ctx, duk_idx_t index)
    cdef void *duk_get_heapptr(duk_context *ctx, duk_idx_t index)
    cdef void duk_push_this(duk_context *ctx)

    # New
    duk_bool_t duk_is_buffer(duk_context *thr, duk_idx_t idx)
    void *duk_get_buffer(duk_context *ctx, duk_idx_t idx, duk_size_t *out_size)
    void duk_join(duk_context *ctx, duk_idx_t count)
    void duk_insert(duk_context *ctx, duk_idx_t to_idx)
    const char *duk_to_string(duk_context *ctx, duk_idx_t idx)

    void duk_push_global_object(duk_context *ctx)
    # Flags for duk_def_prop() and its variants; base flags + a lot of convenience shorthands */
    int DUK_DEFPROP_WRITABLE              # (1U << 0)    /* set writable (effective if DUK_DEFPROP_HAVE_WRITABLE set) */
    int DUK_DEFPROP_ENUMERABLE            # (1U << 1)    /* set enumerable (effective if DUK_DEFPROP_HAVE_ENUMERABLE set) */
    int DUK_DEFPROP_CONFIGURABLE          # (1U << 2)    /* set configurable (effective if DUK_DEFPROP_HAVE_CONFIGURABLE set) */
    int DUK_DEFPROP_RESERVED3             # (1U << 3)    /* INTERNAL: reserved, internally accessor flag */
    int DUK_DEFPROP_RESERVED4             # (1U << 4)    /* INTERNAL: reserved */
    int DUK_DEFPROP_RESERVED5             # (1U << 5)    /* INTERNAL: reserved */
    int DUK_DEFPROP_RESERVED6             # (1U << 6)    /* INTERNAL: reserved */
    int DUK_DEFPROP_RESERVED7             # (1U << 7)    /* INTERNAL: reserved */
    int DUK_DEFPROP_HAVE_SHIFT_COUNT      # 8            /* INTERNAL */
    int DUK_DEFPROP_HAVE_WRITABLE         # (1U << 8)    /* set/clear writable */
    int DUK_DEFPROP_HAVE_ENUMERABLE       # (1U << 9)    /* set/clear enumerable */
    int DUK_DEFPROP_HAVE_CONFIGURABLE     # (1U << 10)   /* set/clear configurable */
    int DUK_DEFPROP_HAVE_VALUE            # (1U << 11)   /* set value (given on value stack) */
    int DUK_DEFPROP_HAVE_GETTER           # (1U << 12)   /* set getter (given on value stack) */
    int DUK_DEFPROP_HAVE_SETTER           # (1U << 13)   /* set setter (given on value stack) */
    int DUK_DEFPROP_FORCE                 # (1U << 14)   /* force change if possible, may still fail for e.g. virtual properties */
    int DUK_DEFPROP_THROW                 # (1U << 15)   /* INTERNAL: throw on errors */
    int DUK_DEFPROP_SET_WRITABLE
    int DUK_DEFPROP_SET_CONFIGURABLE
    void duk_def_prop(duk_context *ctx, duk_idx_t obj_idx, duk_uint_t flags)


cdef extern from "duk_module_duktape.h":
    ctypedef struct duk_context:
        pass
    cdef void duk_module_duktape_init(duk_context *ctx) noexcept

cdef duk_ret_t runtests_print_alert_helper(duk_context *ctx, FILE *fh)
cdef duk_ret_t runtests_print(duk_context *ctx)
cdef duk_ret_t runtests_alert(duk_context *ctx)

cdef class DuktapeError(Exception):
    pass

cdef class DuktapeThreadError(DuktapeError):
    pass

cdef class JSError(Exception):
    pass

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
    cdef unsigned long int thread_id
 
    cdef void _init_alerts_backwards_compat(self)
    cdef void _setup_module_search_function(self)

    # Nitpick, this should be internal and not public to python...
    cdef inline int _check_thread(self) except -1:
        if PyThread_get_thread_ident() != self.thread_id:
            PyErr_SetNone(DuktapeThreadError)
            return -1
        return 0


    cdef void _set_global(self, const char* name, object value)
    cdef object _eval_js(self, bytes src)
    cdef object get_error(self)
    cpdef JSRef make_jsref(self, duk_idx_t index)
    cdef void register_object(self, void *proxy_ptr, object py_obj)
    cdef object get_registered_object(self, void *proxy_ptr)
    cdef int is_registered_object(self, void *proxy_ptr)
    cdef void unregister_object(self, void *proxy_ptr)
    cdef void register_proxy(self, void *proxy_ptr, void *target_ptr, object py_obj)
    cdef object get_registered_object_from_proxy(self, void *proxy_ptr)
    cdef int is_registered_proxy(self, void *proxy_ptr)
    cdef void unregister_proxy_from_target(self, void *target_ptr)

cdef void set_python_context(duk_context *ctx, DuktapeContext py_ctx)
cdef DuktapeContext get_python_context(duk_context *ctx)

cdef class JSRef(object):
    cdef DuktapeContext py_ctx
    cdef int ref_index
    cpdef to_js(self)

ctypedef duk_ret_t (*callfunc)(duk_context*, duk_idx_t)

cdef class JSProxy(object):
    cdef JSRef __ref
    cdef object __bind_proxy
    cdef object __call(self, callfunc call_type, tuple args, this)
    cpdef to_js(self)
cdef duk_ret_t call_new(duk_context *ctx, void *udata)
cdef duk_ret_t safe_new(duk_context *ctx, int nargs)
cdef duk_ret_t module_search(duk_context *ctx)
cdef object to_python(DuktapeContext py_ctx, duk_idx_t index, JSProxy bind_proxy = *)
cdef object get_python_string(duk_context *ctx, duk_idx_t index)
cdef void to_js(duk_context *ctx, object value)
cdef void push_py_proxy(duk_context *ctx, object obj)
cdef duk_ret_t py_proxy_finalizer(duk_context *ctx)
cdef duk_ret_t py_proxy_get(duk_context *ctx)
cdef duk_ret_t py_proxy_has(duk_context *ctx)
cdef duk_ret_t py_proxy_set(duk_context *ctx)
cdef duk_ret_t callback_finalizer(duk_context *ctx)
cdef void push_callback(duk_context *ctx, object fn)
cdef duk_ret_t callback(duk_context *ctx)
