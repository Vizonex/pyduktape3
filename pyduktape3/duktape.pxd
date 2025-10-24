from libc.stdint cimport int16_t as int16_t
from libc.stdint cimport int32_t as int32_t    
from libc.stdint cimport int64_t as int64_t    
from libc.stdint cimport int8_t as int8_t      
from libc.stdint cimport intmax_t as intmax_t  
from libc.stdint cimport intptr_t as intptr_t  
from libc.stdint cimport uint16_t as uint16_t  
from libc.stdint cimport uint32_t as uint32_t  
from libc.stdint cimport uint64_t as uint64_t  
from libc.stdint cimport uint8_t as uint8_t    
from libc.stdint cimport uintmax_t as uintmax_t
from libc.stdint cimport uintptr_t as uintptr_t


# Making up for the pretty large update...

cdef extern from "duk_config.h":    
    struct duk_hthread:
        pass
    ctypedef uint8_t duk_uint8_t
    ctypedef int8_t duk_int8_t
    ctypedef uint16_t duk_uint16_t
    ctypedef int16_t duk_int16_t
    ctypedef uint32_t duk_uint32_t
    ctypedef int32_t duk_int32_t
    ctypedef uint64_t duk_uint64_t
    ctypedef int64_t duk_int64_t
    ctypedef uint8_t duk_uint_least8_t
    ctypedef int8_t duk_int_least8_t
    ctypedef uint16_t duk_uint_least16_t
    ctypedef int16_t duk_int_least16_t
    ctypedef uint32_t duk_uint_least32_t
    ctypedef int32_t duk_int_least32_t
    ctypedef uint64_t duk_uint_least64_t
    ctypedef int64_t duk_int_least64_t
    ctypedef uint8_t duk_uint_fast8_t
    ctypedef int8_t duk_int_fast8_t
    ctypedef uint16_t duk_uint_fast16_t
    ctypedef int16_t duk_int_fast16_t
    ctypedef uint32_t duk_uint_fast32_t
    ctypedef int32_t duk_int_fast32_t
    ctypedef uint64_t duk_uint_fast64_t
    ctypedef int64_t duk_int_fast64_t
    ctypedef uintptr_t duk_uintptr_t
    ctypedef intptr_t duk_intptr_t
    ctypedef uintmax_t duk_uintmax_t
    ctypedef intmax_t duk_intmax_t
    ctypedef size_t duk_size_t
    ctypedef ptrdiff_t duk_ptrdiff_t
    ctypedef int duk_int_t
    ctypedef unsigned int duk_uint_t
    ctypedef duk_int_fast32_t duk_int_fast_t
    ctypedef duk_uint_fast32_t duk_uint_fast_t
    ctypedef int duk_small_int_t
    ctypedef unsigned int duk_small_uint_t
    ctypedef duk_int_fast16_t duk_small_int_fast_t
    ctypedef duk_uint_fast16_t duk_small_uint_fast_t
    ctypedef duk_small_uint_t duk_bool_t
    ctypedef duk_small_int_t duk_sbool_t
    ctypedef duk_int_t duk_idx_t
    ctypedef duk_uint_t duk_uidx_t
    ctypedef duk_uint_t duk_uarridx_t
    ctypedef duk_small_int_t duk_ret_t
    ctypedef duk_int_t duk_errcode_t
    ctypedef duk_int_t duk_codepoint_t
    ctypedef duk_uint_t duk_ucodepoint_t
    ctypedef float duk_float_t
    ctypedef double duk_double_t
    ctypedef duk_hthread duk_context

cdef extern from "duktape.h":
    ctypedef duk_thread_state duk_thread_state
    ctypedef duk_memory_functions duk_memory_functions
    ctypedef duk_function_list_entry duk_function_list_entry
    ctypedef duk_number_list_entry duk_number_list_entry
    ctypedef duk_time_components duk_time_components
    ctypedef duk_ret_t (*duk_c_function)(duk_context*)
    ctypedef void* (*duk_alloc_function)(void*, duk_size_t)
    ctypedef void* (*duk_realloc_function)(void*, void*, duk_size_t)
    ctypedef void (*duk_free_function)(void*, void*)
    ctypedef void (*duk_fatal_function)(void*, const char*)
    ctypedef void (*duk_decode_char_function)(void*, duk_codepoint_t)
    ctypedef duk_codepoint_t (*duk_map_char_function)(void*, duk_codepoint_t)
    ctypedef duk_ret_t (*duk_safe_call_function)(duk_context*, void*)
    ctypedef duk_size_t (*duk_debug_read_function)(void*, char*, duk_size_t)
    ctypedef duk_size_t (*duk_debug_write_function)(void*, const char*, duk_size_t)
    ctypedef duk_size_t (*duk_debug_peek_function)(void*)
    ctypedef void (*duk_debug_read_flush_function)(void*)
    ctypedef void (*duk_debug_write_flush_function)(void*)
    ctypedef duk_idx_t (*duk_debug_request_function)(duk_context*, void*, duk_idx_t)
    ctypedef void (*duk_debug_detached_function)(duk_context*, void*)
    struct duk_thread_state:
        char data[128]
    struct duk_memory_functions:
        duk_alloc_function alloc_func
        duk_realloc_function realloc_func
        duk_free_function free_func
        void* udata
    struct duk_function_list_entry:
        const char* key
        duk_c_function value
        duk_idx_t nargs
    struct duk_number_list_entry:
        const char* key
        duk_double_t value
    struct duk_time_components:
        duk_double_t year
        duk_double_t month
        duk_double_t day
        duk_double_t hours
        duk_double_t minutes
        duk_double_t seconds
        duk_double_t milliseconds
        duk_double_t weekday
    duk_context* duk_create_heap(duk_alloc_function, duk_realloc_function, duk_free_function, void*, duk_fatal_function)
    void duk_destroy_heap(duk_context*)
    void duk_suspend(duk_context*, duk_thread_state*)
    void duk_resume(duk_context*, duk_thread_state*)
    void* duk_alloc_raw(duk_context*, duk_size_t)
    void duk_free_raw(duk_context*, void*)
    void* duk_realloc_raw(duk_context*, void*, duk_size_t)
    void* duk_alloc(duk_context*, duk_size_t)
    void duk_free(duk_context*, void*)
    void* duk_realloc(duk_context*, void*, duk_size_t)
    void duk_get_memory_functions(duk_context*, duk_memory_functions*)
    void duk_gc(duk_context*, duk_uint_t)
    void duk_throw_raw(duk_context*)
    void duk_fatal_raw(duk_context*, const char*)
    void duk_error_raw(duk_context*, duk_errcode_t, const char*, duk_int_t, const char*)
    void duk_error_va_raw(duk_context*, duk_errcode_t, const char*, duk_int_t, const char*, va_list)
    duk_bool_t duk_is_strict_call(duk_context*)
    duk_bool_t duk_is_constructor_call(duk_context*)
    duk_idx_t duk_normalize_index(duk_context*, duk_idx_t)
    duk_idx_t duk_require_normalize_index(duk_context*, duk_idx_t)
    duk_bool_t duk_is_valid_index(duk_context*, duk_idx_t)
    void duk_require_valid_index(duk_context*, duk_idx_t)
    duk_idx_t duk_get_top(duk_context*)
    void duk_set_top(duk_context*, duk_idx_t)
    duk_idx_t duk_get_top_index(duk_context*)
    duk_idx_t duk_require_top_index(duk_context*)
    duk_bool_t duk_check_stack(duk_context*, duk_idx_t)
    void duk_require_stack(duk_context*, duk_idx_t)
    duk_bool_t duk_check_stack_top(duk_context*, duk_idx_t)
    void duk_require_stack_top(duk_context*, duk_idx_t)
    void duk_swap(duk_context*, duk_idx_t, duk_idx_t)
    void duk_swap_top(duk_context*, duk_idx_t)
    void duk_dup(duk_context*, duk_idx_t)
    void duk_dup_top(duk_context*)
    void duk_insert(duk_context*, duk_idx_t)
    void duk_pull(duk_context*, duk_idx_t)
    void duk_replace(duk_context*, duk_idx_t)
    void duk_copy(duk_context*, duk_idx_t, duk_idx_t)
    void duk_remove(duk_context*, duk_idx_t)
    void duk_xcopymove_raw(duk_context*, duk_context*, duk_idx_t, duk_bool_t)
    void duk_push_undefined(duk_context*)
    void duk_push_null(duk_context*)
    void duk_push_boolean(duk_context*, duk_bool_t)
    void duk_push_true(duk_context*)
    void duk_push_false(duk_context*)
    void duk_push_number(duk_context*, duk_double_t)
    void duk_push_nan(duk_context*)
    void duk_push_int(duk_context*, duk_int_t)
    void duk_push_uint(duk_context*, duk_uint_t)
    const char* duk_push_string(duk_context*, const char*)
    const char* duk_push_lstring(duk_context*, const char*, duk_size_t)
    void duk_push_pointer(duk_context*, void*)
    const char* duk_push_sprintf(duk_context*, const char*)
    const char* duk_push_vsprintf(duk_context*, const char*, va_list)
    const char* duk_push_literal_raw(duk_context*, const char*, duk_size_t)
    void duk_push_this(duk_context*)
    void duk_push_new_target(duk_context*)
    void duk_push_current_function(duk_context*)
    void duk_push_current_thread(duk_context*)
    void duk_push_global_object(duk_context*)
    void duk_push_heap_stash(duk_context*)
    void duk_push_global_stash(duk_context*)
    void duk_push_thread_stash(duk_context*, duk_context*)
    duk_idx_t duk_push_object(duk_context*)
    duk_idx_t duk_push_bare_object(duk_context*)
    duk_idx_t duk_push_array(duk_context*)
    duk_idx_t duk_push_bare_array(duk_context*)
    duk_idx_t duk_push_c_function(duk_context*, duk_c_function, duk_idx_t)
    duk_idx_t duk_push_c_lightfunc(duk_context*, duk_c_function, duk_idx_t, duk_idx_t, duk_int_t)
    duk_idx_t duk_push_thread_raw(duk_context*, duk_uint_t)
    duk_idx_t duk_push_proxy(duk_context*, duk_uint_t)
    duk_idx_t duk_push_error_object_raw(duk_context*, duk_errcode_t, const char*, duk_int_t, const char*)
    duk_idx_t duk_push_error_object_va_raw(duk_context*, duk_errcode_t, const char*, duk_int_t, const char*, va_list)
    void* duk_push_buffer_raw(duk_context*, duk_size_t, duk_small_uint_t)
    void duk_push_buffer_object(duk_context*, duk_idx_t, duk_size_t, duk_size_t, duk_uint_t)
    duk_idx_t duk_push_heapptr(duk_context*, void*)
    void duk_pop(duk_context*)
    void duk_pop_n(duk_context*, duk_idx_t)
    void duk_pop_2(duk_context*)
    void duk_pop_3(duk_context*)
    duk_int_t duk_get_type(duk_context*, duk_idx_t)
    duk_bool_t duk_check_type(duk_context*, duk_idx_t, duk_int_t)
    duk_uint_t duk_get_type_mask(duk_context*, duk_idx_t)
    duk_bool_t duk_check_type_mask(duk_context*, duk_idx_t, duk_uint_t)
    duk_bool_t duk_is_undefined(duk_context*, duk_idx_t)
    duk_bool_t duk_is_null(duk_context*, duk_idx_t)
    duk_bool_t duk_is_nullish(duk_context*, duk_idx_t)
    duk_bool_t duk_is_boolean(duk_context*, duk_idx_t)
    duk_bool_t duk_is_number(duk_context*, duk_idx_t)
    duk_bool_t duk_is_nan(duk_context*, duk_idx_t)
    duk_bool_t duk_is_string(duk_context*, duk_idx_t)
    duk_bool_t duk_is_object(duk_context*, duk_idx_t)
    duk_bool_t duk_is_buffer(duk_context*, duk_idx_t)
    duk_bool_t duk_is_buffer_data(duk_context*, duk_idx_t)
    duk_bool_t duk_is_pointer(duk_context*, duk_idx_t)
    duk_bool_t duk_is_lightfunc(duk_context*, duk_idx_t)
    duk_bool_t duk_is_symbol(duk_context*, duk_idx_t)
    duk_bool_t duk_is_array(duk_context*, duk_idx_t)
    duk_bool_t duk_is_function(duk_context*, duk_idx_t)
    duk_bool_t duk_is_c_function(duk_context*, duk_idx_t)
    duk_bool_t duk_is_ecmascript_function(duk_context*, duk_idx_t)
    duk_bool_t duk_is_bound_function(duk_context*, duk_idx_t)
    duk_bool_t duk_is_thread(duk_context*, duk_idx_t)
    duk_bool_t duk_is_constructable(duk_context*, duk_idx_t)
    duk_bool_t duk_is_dynamic_buffer(duk_context*, duk_idx_t)
    duk_bool_t duk_is_fixed_buffer(duk_context*, duk_idx_t)
    duk_bool_t duk_is_external_buffer(duk_context*, duk_idx_t)
    duk_errcode_t duk_get_error_code(duk_context*, duk_idx_t)
    duk_bool_t duk_get_boolean(duk_context*, duk_idx_t)
    duk_double_t duk_get_number(duk_context*, duk_idx_t)
    duk_int_t duk_get_int(duk_context*, duk_idx_t)
    duk_uint_t duk_get_uint(duk_context*, duk_idx_t)
    const char* duk_get_string(duk_context*, duk_idx_t)
    const char* duk_get_lstring(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_get_buffer(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_get_buffer_data(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_get_pointer(duk_context*, duk_idx_t)
    duk_c_function duk_get_c_function(duk_context*, duk_idx_t)
    duk_context* duk_get_context(duk_context*, duk_idx_t)
    void* duk_get_heapptr(duk_context*, duk_idx_t)
    duk_bool_t duk_get_boolean_default(duk_context*, duk_idx_t, duk_bool_t)
    duk_double_t duk_get_number_default(duk_context*, duk_idx_t, duk_double_t)
    duk_int_t duk_get_int_default(duk_context*, duk_idx_t, duk_int_t)
    duk_uint_t duk_get_uint_default(duk_context*, duk_idx_t, duk_uint_t)
    const char* duk_get_string_default(duk_context*, duk_idx_t, const char*)
    const char* duk_get_lstring_default(duk_context*, duk_idx_t, duk_size_t*, const char*, duk_size_t)
    void* duk_get_buffer_default(duk_context*, duk_idx_t, duk_size_t*, void*, duk_size_t)
    void* duk_get_buffer_data_default(duk_context*, duk_idx_t, duk_size_t*, void*, duk_size_t)
    void* duk_get_pointer_default(duk_context*, duk_idx_t, void*)
    duk_c_function duk_get_c_function_default(duk_context*, duk_idx_t, duk_c_function)
    duk_context* duk_get_context_default(duk_context*, duk_idx_t, duk_context*)
    void* duk_get_heapptr_default(duk_context*, duk_idx_t, void*)
    duk_bool_t duk_opt_boolean(duk_context*, duk_idx_t, duk_bool_t)
    duk_double_t duk_opt_number(duk_context*, duk_idx_t, duk_double_t)
    duk_int_t duk_opt_int(duk_context*, duk_idx_t, duk_int_t)
    duk_uint_t duk_opt_uint(duk_context*, duk_idx_t, duk_uint_t)
    const char* duk_opt_string(duk_context*, duk_idx_t, const char*)
    const char* duk_opt_lstring(duk_context*, duk_idx_t, duk_size_t*, const char*, duk_size_t)
    void* duk_opt_buffer(duk_context*, duk_idx_t, duk_size_t*, void*, duk_size_t)
    void* duk_opt_buffer_data(duk_context*, duk_idx_t, duk_size_t*, void*, duk_size_t)
    void* duk_opt_pointer(duk_context*, duk_idx_t, void*)
    duk_c_function duk_opt_c_function(duk_context*, duk_idx_t, duk_c_function)
    duk_context* duk_opt_context(duk_context*, duk_idx_t, duk_context*)
    void* duk_opt_heapptr(duk_context*, duk_idx_t, void*)
    void duk_require_undefined(duk_context*, duk_idx_t)
    void duk_require_null(duk_context*, duk_idx_t)
    duk_bool_t duk_require_boolean(duk_context*, duk_idx_t)
    duk_double_t duk_require_number(duk_context*, duk_idx_t)
    duk_int_t duk_require_int(duk_context*, duk_idx_t)
    duk_uint_t duk_require_uint(duk_context*, duk_idx_t)
    const char* duk_require_string(duk_context*, duk_idx_t)
    const char* duk_require_lstring(duk_context*, duk_idx_t, duk_size_t*)
    void duk_require_object(duk_context*, duk_idx_t)
    void* duk_require_buffer(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_require_buffer_data(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_require_pointer(duk_context*, duk_idx_t)
    duk_c_function duk_require_c_function(duk_context*, duk_idx_t)
    duk_context* duk_require_context(duk_context*, duk_idx_t)
    void duk_require_function(duk_context*, duk_idx_t)
    void duk_require_constructor_call(duk_context*)
    void duk_require_constructable(duk_context*, duk_idx_t)
    void* duk_require_heapptr(duk_context*, duk_idx_t)
    void duk_to_undefined(duk_context*, duk_idx_t)
    void duk_to_null(duk_context*, duk_idx_t)
    duk_bool_t duk_to_boolean(duk_context*, duk_idx_t)
    duk_double_t duk_to_number(duk_context*, duk_idx_t)
    duk_int_t duk_to_int(duk_context*, duk_idx_t)
    duk_uint_t duk_to_uint(duk_context*, duk_idx_t)
    duk_int32_t duk_to_int32(duk_context*, duk_idx_t)
    duk_uint32_t duk_to_uint32(duk_context*, duk_idx_t)
    duk_uint16_t duk_to_uint16(duk_context*, duk_idx_t)
    const char* duk_to_string(duk_context*, duk_idx_t)
    const char* duk_to_lstring(duk_context*, duk_idx_t, duk_size_t*)
    void* duk_to_buffer_raw(duk_context*, duk_idx_t, duk_size_t*, duk_uint_t)
    void* duk_to_pointer(duk_context*, duk_idx_t)
    void duk_to_object(duk_context*, duk_idx_t)
    void duk_to_primitive(duk_context*, duk_idx_t, duk_int_t)
    const char* duk_safe_to_lstring(duk_context*, duk_idx_t, duk_size_t*)
    const char* duk_to_stacktrace(duk_context*, duk_idx_t)
    const char* duk_safe_to_stacktrace(duk_context*, duk_idx_t)
    duk_size_t duk_get_length(duk_context*, duk_idx_t)
    void duk_set_length(duk_context*, duk_idx_t, duk_size_t)
    const char* duk_base64_encode(duk_context*, duk_idx_t)
    void duk_base64_decode(duk_context*, duk_idx_t)
    const char* duk_hex_encode(duk_context*, duk_idx_t)
    void duk_hex_decode(duk_context*, duk_idx_t)
    const char* duk_json_encode(duk_context*, duk_idx_t)
    void duk_json_decode(duk_context*, duk_idx_t)
    void duk_cbor_encode(duk_context*, duk_idx_t, duk_uint_t)
    void duk_cbor_decode(duk_context*, duk_idx_t, duk_uint_t)
    const char* duk_buffer_to_string(duk_context*, duk_idx_t)
    void* duk_resize_buffer(duk_context*, duk_idx_t, duk_size_t)
    void* duk_steal_buffer(duk_context*, duk_idx_t, duk_size_t*)
    void duk_config_buffer(duk_context*, duk_idx_t, void*, duk_size_t)
    duk_bool_t duk_get_prop(duk_context*, duk_idx_t)
    duk_bool_t duk_get_prop_string(duk_context*, duk_idx_t, const char*)
    duk_bool_t duk_get_prop_lstring(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_get_prop_literal_raw(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_get_prop_index(duk_context*, duk_idx_t, duk_uarridx_t)
    duk_bool_t duk_get_prop_heapptr(duk_context*, duk_idx_t, void*)
    duk_bool_t duk_put_prop(duk_context*, duk_idx_t)
    duk_bool_t duk_put_prop_string(duk_context*, duk_idx_t, const char*)
    duk_bool_t duk_put_prop_lstring(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_put_prop_literal_raw(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_put_prop_index(duk_context*, duk_idx_t, duk_uarridx_t)
    duk_bool_t duk_put_prop_heapptr(duk_context*, duk_idx_t, void*)
    duk_bool_t duk_del_prop(duk_context*, duk_idx_t)
    duk_bool_t duk_del_prop_string(duk_context*, duk_idx_t, const char*)
    duk_bool_t duk_del_prop_lstring(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_del_prop_literal_raw(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_del_prop_index(duk_context*, duk_idx_t, duk_uarridx_t)
    duk_bool_t duk_del_prop_heapptr(duk_context*, duk_idx_t, void*)
    duk_bool_t duk_has_prop(duk_context*, duk_idx_t)
    duk_bool_t duk_has_prop_string(duk_context*, duk_idx_t, const char*)
    duk_bool_t duk_has_prop_lstring(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_has_prop_literal_raw(duk_context*, duk_idx_t, const char*, duk_size_t)
    duk_bool_t duk_has_prop_index(duk_context*, duk_idx_t, duk_uarridx_t)
    duk_bool_t duk_has_prop_heapptr(duk_context*, duk_idx_t, void*)
    void duk_get_prop_desc(duk_context*, duk_idx_t, duk_uint_t)
    void duk_def_prop(duk_context*, duk_idx_t, duk_uint_t)
    duk_bool_t duk_get_global_string(duk_context*, const char*)
    duk_bool_t duk_get_global_lstring(duk_context*, const char*, duk_size_t)
    duk_bool_t duk_get_global_literal_raw(duk_context*, const char*, duk_size_t)
    duk_bool_t duk_get_global_heapptr(duk_context*, void*)
    duk_bool_t duk_put_global_string(duk_context*, const char*)
    duk_bool_t duk_put_global_lstring(duk_context*, const char*, duk_size_t)
    duk_bool_t duk_put_global_literal_raw(duk_context*, const char*, duk_size_t)
    duk_bool_t duk_put_global_heapptr(duk_context*, void*)
    void duk_inspect_value(duk_context*, duk_idx_t)
    void duk_inspect_callstack_entry(duk_context*, duk_int_t)
    void duk_get_prototype(duk_context*, duk_idx_t)
    void duk_set_prototype(duk_context*, duk_idx_t)
    void duk_get_finalizer(duk_context*, duk_idx_t)
    void duk_set_finalizer(duk_context*, duk_idx_t)
    void duk_set_global_object(duk_context*)
    duk_int_t duk_get_magic(duk_context*, duk_idx_t)
    void duk_set_magic(duk_context*, duk_idx_t, duk_int_t)
    duk_int_t duk_get_current_magic(duk_context*)
    void duk_put_function_list(duk_context*, duk_idx_t, duk_function_list_entry*)
    void duk_put_number_list(duk_context*, duk_idx_t, duk_number_list_entry*)
    void duk_compact(duk_context*, duk_idx_t)
    void duk_enum(duk_context*, duk_idx_t, duk_uint_t)
    duk_bool_t duk_next(duk_context*, duk_idx_t, duk_bool_t)
    void duk_seal(duk_context*, duk_idx_t)
    void duk_freeze(duk_context*, duk_idx_t)
    void duk_concat(duk_context*, duk_idx_t)
    void duk_join(duk_context*, duk_idx_t)
    void duk_decode_string(duk_context*, duk_idx_t, duk_decode_char_function, void*)
    void duk_map_string(duk_context*, duk_idx_t, duk_map_char_function, void*)
    void duk_substring(duk_context*, duk_idx_t, duk_size_t, duk_size_t)
    void duk_trim(duk_context*, duk_idx_t)
    duk_codepoint_t duk_char_code_at(duk_context*, duk_idx_t, duk_size_t)
    duk_bool_t duk_equals(duk_context*, duk_idx_t, duk_idx_t)
    duk_bool_t duk_strict_equals(duk_context*, duk_idx_t, duk_idx_t)
    duk_bool_t duk_samevalue(duk_context*, duk_idx_t, duk_idx_t)
    duk_bool_t duk_instanceof(duk_context*, duk_idx_t, duk_idx_t)
    duk_double_t duk_random(duk_context*)
    void duk_call(duk_context*, duk_idx_t)
    void duk_call_method(duk_context*, duk_idx_t)
    void duk_call_prop(duk_context*, duk_idx_t, duk_idx_t)
    duk_int_t duk_pcall(duk_context*, duk_idx_t)
    duk_int_t duk_pcall_method(duk_context*, duk_idx_t)
    duk_int_t duk_pcall_prop(duk_context*, duk_idx_t, duk_idx_t)
    void duk_new(duk_context*, duk_idx_t)
    duk_int_t duk_pnew(duk_context*, duk_idx_t)
    duk_int_t duk_safe_call(duk_context*, duk_safe_call_function, void*, duk_idx_t, duk_idx_t)
    duk_int_t duk_eval_raw(duk_context*, const char*, duk_size_t, duk_uint_t)
    duk_int_t duk_compile_raw(duk_context*, const char*, duk_size_t, duk_uint_t)
    void duk_dump_function(duk_context*)
    void duk_load_function(duk_context*)
    void duk_push_context_dump(duk_context*)
    void duk_debugger_attach(duk_context*, duk_debug_read_function, duk_debug_write_function, duk_debug_peek_function, duk_debug_read_flush_function, duk_debug_write_flush_function, duk_debug_request_function, duk_debug_detached_function, void*)
    void duk_debugger_detach(duk_context*)
    void duk_debugger_cooperate(duk_context*)
    duk_bool_t duk_debugger_notify(duk_context*, duk_idx_t)
    void duk_debugger_pause(duk_context*)
    duk_double_t duk_get_now(duk_context*)
    void duk_time_to_components(duk_context*, duk_double_t, duk_time_components*)
    duk_double_t duk_components_to_time(duk_context*, duk_time_components*)


    # Custom
    duk_error(duk_context* ctx, duk_errcode_t errcode, const char* error)


