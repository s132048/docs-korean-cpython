.. _development:

*****************
개발 도구
*****************

이 장의 모듈은 소프트웨어 개발을 돕기 위한 것들이다.
For example, the
:mod:`pydoc` module takes a module and generates documentation based on the
module's contents.  The :mod:`doctest` and :mod:`unittest` modules contains
frameworks for writing unit tests that automatically exercise code and verify
that the expected output is produced.  :program:`2to3` can translate Python 2.x
source code into valid Python 3.x code.

The list of modules described in this chapter is:


.. toctree::

   typing.rst
   pydoc.rst
   doctest.rst
   unittest_ko.rst
   unittest.mock.rst
   unittest.mock-examples.rst
   2to3.rst
   test.rst

See also the Python development mode: the :option:`-X` ``dev`` option and
:envvar:`PYTHONDEVMODE` environment variable.
