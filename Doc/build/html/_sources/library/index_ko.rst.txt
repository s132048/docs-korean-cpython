.. _library-index:

###############################
파이썬 표준 라이브러리
###############################


:ref:`reference-index` 문서가 파이썬 언어의 정확한 문법과 의미를 기술하고 있는데 반해
이 라이브러리 참조 매뉴얼은 파이썬과 같이 배포되는 표준 라이브러리에 대해 기술한다.
또한 파이썬 배포시 자주 표함되는 몇가지 추가 구성요소에 대해서도 기술한다.

파이썬의 표준 라이브러리는 매우 방대하고 아래의 긴 목차가 말해주듯이 다양한 기능을 제공하고 있다.
라이브러리에는 파이썬 프로그래머가 직접 접근할 수 없는 파일 입출력과 같이 시스템 기능에 대한 접근을
제공하기 위한 (C로 씌여진) 내장 모듈도 있고
일상적인 프로그래밍에서 발생하는 많은 문제들을 풀기위한 표준 해결방법을 제공하는 파이썬으로 씌여진 모듈로 있다.
이 모듈 중 일부는 특정한 플랫폼 기능들을 플랫폼 중립적인 API로 추상화하여
파이썬 프로그램의 호환성을 강화하고 촉진하기 위한 목적으로 설계되었다.

윈도우용 파이썬 설치 프로그램은 표준 라이브러리를 모두 포함하여 추가적인 구성요소도 많이 가지고 있다.
유닉스 호환 운영체제용 파이썬은 패키지 모듬 형태로 제공되므로
각 운영체제에 있는 패키지 도구로 추가 구성요소를 설치해야 한다.

표준 라이브러리 뿐 아니라 (개별 프로그램부터 패키지 모듈, 그리고 어플리케이션 개발 프레임워크에 이르기까지)
수천개의 구성요소들이 계속 생겨나고 있으며 `Python Package Index <https://pypi.python.org/pypi>`_\ 에서
내려받을 수 있다.


.. toctree::
   :maxdepth: 2
   :numbered:

   intro.rst
   functions.rst
   constants.rst
   stdtypes_ko.rst
   exceptions.rst

   text.rst
   binary.rst
   datatypes.rst
   numeric.rst
   functional.rst
   filesys.rst
   persistence.rst
   archiving.rst
   fileformats.rst
   crypto.rst
   allos_ko.rst
   concurrency.rst
   ipc.rst
   netdata.rst
   markup.rst
   internet.rst
   mm.rst
   i18n.rst
   frameworks.rst
   tk.rst
   development_ko.rst
   debug_ko.rst
   distribution.rst
   python.rst
   custominterp.rst
   modules.rst
   language.rst
   misc.rst
   windows.rst
   unix.rst
   superseded.rst
   undoc.rst
