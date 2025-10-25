"""
Pyduktape3
----------

The third iteration of a duktape wrapper for python and cython libraries.

"""

from ._pyduktape3 import (
    DuktapeError,
    DuktapeThreadError,
    JSError,
    DuktapeContext,
    JSRef,
    JSProxy,
    DUK_TYPE_NONE,
    DUK_TYPE_UNDEFINED,
    DUK_TYPE_NULL,
    DUK_TYPE_BOOLEAN,
    DUK_TYPE_NUMBER,
    DUK_TYPE_STRING,
    DUK_TYPE_OBJECT,
    DUK_TYPE_BUFFER,
    DUK_TYPE_POINTER,
    DUK_TYPE_LIGHTFUNC,
    DUK_ENUM_OWN_PROPERTIES_ONLY,
    DUK_VARARGS,
    DUK_ERR_ERROR
)

__author__ = "Vizonex"
__license__ = "GPL 2.1"

__all__ = (
    "DUK_ENUM_OWN_PROPERTIES_ONLY",
    "DUK_ERR_ERROR",
    "DUK_TYPE_BOOLEAN",
    "DUK_TYPE_BUFFER",
    "DUK_TYPE_LIGHTFUNC",
    "DUK_TYPE_NONE",
    "DUK_TYPE_NULL",
    "DUK_TYPE_NUMBER",
    "DUK_TYPE_OBJECT",
    "DUK_TYPE_POINTER",
    "DUK_TYPE_STRING",
    "DUK_TYPE_UNDEFINED",
    "DUK_VARARGS",
    "DuktapeContext",
    "DuktapeError",
    "DuktapeThreadError",
    "JSError",
    "JSProxy",
    "JSRef",
    "__author__",
    "__license__",
)