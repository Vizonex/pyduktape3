# pyduktape3
A Rewrite of pyduktape and pyduktape2 with extended features, typehinting support and cython importable data.

> [!Warning]
> duktape is an __Unmaintained C Library__ and probably will end up being unmaintained unless a miracle happens
> and soemone steps in and adds in ECMA6. If your looking for a javascript backend that is maintained,
> try [CYJS](https://github.com/Vizonex/cyjs) It can tackle and rip through html5 easily and has a friendlier
> License all together.


# Documentation

## Threading
It is possible to invoke Javascript code from multiple threads. Each
thread will need to use its own embedded interpreter. Javascript
objects returned to the Python environment will only be usable on the
same thread that created them. The runtime always checks this
condition automatically, and raises a ``DuktapeThreadError`` if it's
violated.

## Getting Started

Installation
------------

To install from pypi::

    pip install pyduktape3

To install the latest version from github::

    pip install git+https://github.com/Vizonex/pyduktape3

Extra help
----------
Typehints are now avalible since pyduktape3 now that a stub file (.pyi extension) 
is included so tools like vscode pyright should be able to pick up on typehints now. 
If this was a annoyance for you with the 2 original packages glad it's been gotten 
rid of now, it was the main reason behind this version's creation :)

Running Javascript code
-----------------------

To run Javascript code, you need to create an execution context and
use the method ``eval_js``::

    import pyduktape3

    context = pyduktape3.DuktapeContext()
    context.eval_js("print(Duktape.version);")

Each execution context starts its own interpreter. Each context is
independent, and tied to the Python thread that created it. Memory is
automatically managed.


To evaluate external Javascript files, use ``eval_js_file``::

    // helloWorld.js
    print('Hello, World!');

    # in the Python interpreter
    import pyduktape3

    context = pyduktape3.DuktapeContext()
    context.eval_js_file('helloWorld.js')

Pyduktape supports Javascript modules::

    // js/helloWorld.js
    exports.sayHello = function () {
        print('Hello, World!');
    };

    // js/main.js
    var helloWorld = require('js/helloWorld');
    helloWorld.sayHello();

    # in the Python interpreter
    import pyduktape3

    context = pyduktape3.DuktapeContext()
    context.eval_js_file('js/main')

The ``.js`` extension is automatically added if missing.  Relative
paths are relative to the current working directory, but you can
change the base path using ``set_base_path``::

    # js/helloWorld.js
    print('Hello, World!');

    # in the Python interpreter
    import pyduktape3

    context = pyduktape3.DuktapeContext()
    context.set_base_path('js')
    context.eval_js_file('helloWorld')

Python and Javascript integration
---------------------------------

You can use ``set_globals`` to set Javascript global variables::

    import pyduktape3

    def say_hello(to):
        print('Hello, {}!'.format(to))

    context = pyduktape3.DuktapeContext()
    context.set_globals(sayHello=say_hello, world='World')
    context.eval_js("sayHello(world);")

You can use ``get_global`` to access Javascript global variables::

    import pyduktape3

    context = pyduktape3.DuktapeContext()
    context.eval_js("var helloWorld = 'Hello, World!';")
    print(context.get_global('helloWorld'))

``eval_js`` returns the value of the last expression::

    import pyduktape3

    context = pyduktape3.DuktapeContext()
    hello_world = context.eval_js("var helloWorld = 'Hello, World!'; helloWorld")
    print(hello_world)

You can seamlessly use Python objects and functions within Javascript
code.  There are some limitations, though: any Python callable can
only be used as a function, and other attributes cannot be
accessed. Primitive types (int, float, string, None) are converted to
equivalent Javascript primitives.  The following code shows how to
interact with a Python object from Javascript::

    import pyduktape3

    class Hello(object):
        def __init__(self, what):
            self.what = what

        def say(self):
            print('Hello, {}!'.format(self.what))

    context = pyduktape3.DuktapeContext()
    context.set_globals(Hello=Hello)
    context.eval_js("var helloWorld = Hello('World'); helloWorld.say();")

In the same way, you can use Javascript objects in Python.  You can
use the special method `new` to instantiate an object::

    import pyduktape3

    context = pyduktape3.DuktapeContext()
    Hello = context.eval_js("""
    function Hello(what) {
        this.what = what;
    }

    Hello.prototype.say = function () {
        print('Hello, ' + this.what + '!');
    };

    Hello
    """)

    hello_world = Hello.new('World')
    hello_world.say()

You can use Python lists and dicts from Javascript, and viceversa::

    import pyduktape3

    context = pyduktape3.DuktapeContext()
    res = context.eval_js('[1, 2, 3]')

    for item in res:
        print(item)

    context.set_globals(lst=[4, 5, 6])
    context.eval_js('for (var i = 0; i < lst.length; i++) { print(lst[i]); }')

    res = context.eval_js('var x = {a: 1, b: 2}; x')
    for key, val in res.items():
        print(key, '=', val)
    res.c = 3
    context.eval_js('print(x.c);')

    context.set_globals(x=dict(a=1, b=2))
    context.eval_js("""
    var items = x.items();
    for (var i = 0; i < items.length; i++) {
        print(items[i][0] + ' = ' + items[i][1]);
    }
    """)
    context.set_globals(x=dict(a=1, b=2))
    context.eval_js('for (var k in x) { print(k + " = " + x[k]); }')

## Using in Cython
You can now extend this library and give it new meaning to your program and it's speed in execution::

    cimport pyduktape3
    cdef DuktapeContext context = pyduktape3.DuktapeContext()

