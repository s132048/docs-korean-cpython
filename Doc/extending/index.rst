.. _extending-index:

################################################################################
  파이썬 인터프리터의 확장(extending)과 임베딩(embedding)
################################################################################

이 문서는 C나 C++로 모듈을 작성하고 그 모듈로 파이썬 인터프리터를 확장하는 방법을
설명한다. 모듈에서 새로운 함수를 정의하거나 새로운 객체 타입과 메서드를 정의할
수도 있다.
이 문서에서는 파이썬 인터프리터를 다른 애플리케이션에 임베딩(embedding)하는 법도
설명한다.
마지막으로 확장 모듈을 컴파일하고 링크하여 파이썬 인터프리터가 이 모듈을
다이나믹하게 런타임 로딩하는 법(만약 운영체제가 이 기능을 제공한다면)도 보인다.

이 문서에서는 여러분이 파이썬에 대한 기본 지식을 가지고 있다고 가정한다.
파이썬 언어에 대한 소개는 :ref:`tutorial-index`\ 를 참조한다.
좀 더 정확한 언어 정의는 :ref:`reference-index`\ 를 참조한다.
:ref:`library-index` 문서는 현존하는 객체 타입과 함수, 그리고 모듈을
(빌트인과 파이썬으로 씌여진 것 모두) 소개한다.
이러한 기능로 인해 파이썬 언어는 폭넓은 응용 가능성을 가진다.

파이썬/C API에 대한 자세한 설명은 별도의 :ref:`c-api-index` 문서를 참조한다.


Recommended third party tools
=============================

This guide only covers the basic tools for creating extensions provided
as part of this version of CPython. Third party tools like Cython,
``cffi``, SWIG and Numba offer both simpler and more sophisticated
approaches to creating C and C++ extensions for Python.

.. seealso::

   `Python Packaging User Guide: Binary Extensions <https://packaging.python.org/en/latest/extensions/>`_
      The Python Packaging User Guide not only covers several available
      tools that simplify the creation of binary extensions, but also
      discusses the various reasons why creating an extension module may be
      desirable in the first place.


Creating extensions without third party tools
=============================================

This section of the guide covers creating C and C++ extensions without
assistance from third party tools. It is intended primarily for creators
of those tools, rather than being a recommended way to create your own
C extensions.

.. toctree::
   :maxdepth: 2
   :numbered:

   extending.rst
   newtypes.rst
   building.rst
   windows.rst

Embedding the CPython runtime in a larger application
=====================================================

Sometimes, rather than creating an extension that runs inside the Python
interpreter as the main application, it is desirable to instead embed
the CPython runtime inside a larger application. This section covers
some of the details involved in doing that successfully.

.. toctree::
   :maxdepth: 2
   :numbered:

   embedding.rst
