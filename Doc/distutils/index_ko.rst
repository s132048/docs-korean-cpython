.. _distutils-index:

##############################################
파이썬 모듈 (레거시 버전) 배포
##############################################

:Authors: Greg Ward, Anthony Baxter
:Email: distutils-sig@python.org

.. seealso::

   :ref:`distributing-index`
      The up to date module distribution documentations

이 문서는 파이써너 모듈 배포 유틸리인 Distutils(Distribution Utilities)에 대해
모듈 개발자의 관점에서 설명한다.
Distutils을 사용하여 파이썬 모듈과 확장모듈을 만드는 방법과
더 많은 사람이 사용할 수 있도록 빌드/릴리스/설치 메커니즘을 설명한다.

.. note::

   이 가이드는 해당 버전의 파이썬의 일부로 제공되는 확장모듈을 빌드하고 배포하는
   기본적인 도구만 다룬다. 써드파티 도구들은 더 쉽고 안전한 대안을 제공한다.
   파이썬 패키징에 대한 더 자세한 내용은 파이썬 패키징 사용자 가이드(Python Packaging User Guide)
   `quick recommendations section <https://packaging.python.org/en/latest/current/>`__\ 을 참고하라.

.. toctree::
   :maxdepth: 2
   :numbered:

   introduction.rst
   setupscript.rst
   configfile.rst
   sourcedist.rst
   builtdist.rst
   packageindex.rst
   examples.rst
   extending.rst
   commandref.rst
   apiref.rst
