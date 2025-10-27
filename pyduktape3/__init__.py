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
    JSProxy
)

__author__ = "Vizonex"
__license__ = "GPL 2.1"

__all__ = (
    "DuktapeContext",
    "DuktapeError",
    "DuktapeThreadError",
    "JSError",
    "JSProxy",
    "JSRef",
    "__author__",
    "__license__",
)