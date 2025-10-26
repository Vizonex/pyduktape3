# Allow users to compile pyduktape3 on over to cython, 
# a duplicate of duk_config.h and duktape.h are included
# to help if lower level access is needed...
from ._pyduktape3 cimport *

