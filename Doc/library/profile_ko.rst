.. _profile:

****************************************
파이썬 프로파일러
****************************************

**Source code:** :source:`Lib/profile.py` and :source:`Lib/pstats.py`

--------------

.. _profiler-introduction:

프로파일러 소개
=============================

.. index::
   single: 결정론적 프로파일링
   single: profiling, deterministic

:mod:`cProfile`\ 와 :mod:`profile`\ 는 파이썬 프로그램을
:dfn:`결정론적 프로파일링(deterministic profiling)`\ 하기 위한 것이다.
A :dfn:`프로파일(profile)`\ 은 프로그램의 각 부분이 얼마나 자주, 그리고 얼마나 오랫동안
실행되는지를 묘사한 통계 집합이다.
이 통계는 :mod:`pstats`\ 모듈을 사용하여 리포트 형태로 만들 수 있다.

파이썬 표준 라이브러리는 동일한 프로파일링 인터페이스를 가진 두 개의 다른 구현을 제공한다.:

1. :mod:`cProfile`\ 는 대부분의 사용자에게 추천한다.
   오랫동안 실행되는 프로그램에 적합하도록 오버헤드를 줄인 C 익스텐션(extension)이다.
   Brett Rosen과 Ted Czotter가 만든 :mod:`lsprof`\ 에 기반하고 있다.

2. :mod:`profile`\ 는 :mod:`cProfile`\ 의 인터페이스를 흉내낸 순수 파이썬 모듈로
   프로그램에 추가되는 오버헤드가 크다.
   프로파일러를 어떻게든 확장해보려고 할 때 이 모듈을 사용하면 일이 쉬워질 수 있다.
   Jim Roskind가 설계하고 구현하였다.

.. note::

   프로파일러 모듈은 주어진 프로그램의 실행 프로필을 제공하도록 설계된 것이지
   벤치마킹 목적으로 만들어지지 않았다. (벤치마크용으로는 :mod:`timeit`\ 이 적합하다.)
   특히 파이썬 코드와 C를 비교하여 벤치마킹할 경우, 프로파일러가 파이썬 코드에는
   오버헤드를 주고 C-레벨 함수에는 영향이 없으므로 C 코드가 파이썬 코드보다 빠르게
   보인다.


.. _profile-instant:

즉석 사용자 매뉴얼
==========================================

이 절은 매뉴얼 전체를 읽고 싶어하지 않은 사용자를 위한 절이다.
아주 간단한 개요만 제공하고 지금 있는 애플리케이션을 일단 프로파일링해 볼 수 있도록 한다.

인수를 하나만 가지는 함수를 프로파일링하려면 다음처럼 한다.::

   import cProfile
   import re
   cProfile.run('re.compile("foo|bar")')

(만약 시스템에서 :mod:`cProfile`\ 가 동작하지않으면 대신 :mod:`profile`\ 를 쓸 수 있다.)

위와 같이 :func:`re.compile`\ 를 실행하면 다음처럼 프로파일 결과를 출력한다::

         197 function calls (192 primitive calls) in 0.002 seconds

   Ordered by: standard name

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.000    0.000    0.001    0.001 <string>:1(<module>)
        1    0.000    0.000    0.001    0.001 re.py:212(compile)
        1    0.000    0.000    0.001    0.001 re.py:268(_compile)
        1    0.000    0.000    0.000    0.000 sre_compile.py:172(_compile_charset)
        1    0.000    0.000    0.000    0.000 sre_compile.py:201(_optimize_charset)
        4    0.000    0.000    0.000    0.000 sre_compile.py:25(_identityfunction)
      3/1    0.000    0.000    0.000    0.000 sre_compile.py:33(_compile)

첫줄은 197개의 함수호출이 있었다는 것을 보인다. 이 중에서 192개는 :dfn:`primitive`
즉, 재귀(recursion)에 의한 것이 아니다.
다음 줄의 ``Ordered by: standard name`` 표시는 결과가 가장 오른쪽 열의 문자열을 기준으로
정렬되었다는 뜻이다.
각 열의 의미는 다음과 같다.:

ncalls
   함수 호출 횟수

tottime
   해당 함수에서 사용된 총 시간(하위 함수 호출에 소요된 시간은 제외한다.)

percall
   ``tottime``\ 을 ``ncalls``\ 로 나눈 값

cumtime
   해당 함수와 모든 하위 함수에서 (함수 호출 시작부터 종료까지) 소비된 시간의 누적.
   이 수치는 재귀함수에서도 정확한 값이다.

percall
   ``cumtime``\ 을 primitive 호출 횟수로 나눈 값

filename:lineno(function)
   각 함수에 대한 정보

첫번째 열의 숫자 두 개(예를 들어 ``3/1``)는 함수의 재귀 횟수를 뜻한다.
두번째 숫자는 primitive 호출 횟수이고 앞의 숫자는 전체 호출 횟수이다.
재귀함수가 아니면 두 값이 같으므로 하나만 표시된다.

프로파일 종료시에 결과를 인쇄하지 않고 파일에 저장하려면 :func:`run`\ 에
파일 이름을 명시한다.::

   import cProfile
   import re
   cProfile.run('re.compile("foo|bar")', 'restats')

:class:`pstats.Stats` 클래스는 이 파일의 프로파일 결과를 읽어 여러가지 형태로 바꿀 수 있다.
예를 들어::

   python -m cProfile [-o output_file] [-s sort_order] (-m module | myscript.py)

``-o`` 프로파일 결과를 표준출력이 아닌 파일에 쓴다.

``-s`` :func:`~pstats.Stats.sort_stats` 결과를 해당 기준으로 정렬한다. ``-o``\ 이 없을 때만 가능하다.

``-m`` 스크립트 대신에 모듈을 제공한다.

   .. versionadded:: 3.7
      ``-m`` 옵션 추가.

:mod:`pstats` 모듈의 :class:`~pstats.Stats` 클래스는 프로파일 결과 파일에 저장된 데이터를
조작하고 인쇄하는 다양한 메서드를 가지고 있다.::

   import pstats
   p = pstats.Stats('restats')
   p.strip_dirs().sort_stats(-1).print_stats()

위 예시에서서 사용된 메서드들은 다음과 같은 역할을 한다.
:meth:`~pstats.Stats.strip_dirs` 메서드는 모든 모듈 이름으로부터 불필요한 경로명을 삭제한다.
:meth:`~pstats.Stats.sort_stats` 메서드는 인쇄되는 표준 모듈/행/이름 문자열에 따라 모든 항목을 정렬한다.
:meth:`~pstats.Stats.print_stats` 메서드는 모든 통계를 인쇄한다. 다음과 같은 정 호출을 시도할 수 있다. ::

   p.sort_stats('name')
   p.print_stats()

첫번째 호출은 실제로 함수명에 따라 목록을 정렬하고 두번째 호출이 통계를 인쇄한다.
다음과 같은 흥미로운 호출도 시험해볼 수 있다. ::

   p.sort_stats('cumulative').print_stats(10)

이 호출은 프로파일을 함수의 누적 시간에 따라 정렬하고 가장 중요한 열개의 라인만을 인쇄한다.
어떤 알고리즘이 시간을 잡아먹는지 알고 싶다면 위 예시를 사용할 수 있다.

어떤 함수가 루프를 많이 돌아 긴 시간을 잡아먹는지 알고 싶다면 다음을 사용한다. ::

   p.sort_stats('time').print_stats(10)

각 함수가 사용한 시간에 따라 정렬되고 상위 열개 함수를 인쇄한다.

다음 호출도 시도해볼 수 있다. ::

   p.sort_stats('file').print_stats('__init__')

이 호출은 모든 통계를 파일명에 따라 정렬하고 init 메서드 클래스와 관련된 통계만을 인쇄한다.
(``__init__``\ 을 인수로 넣었기 때문이다.) 마지막 예시로 다음 호출을 시도해보자. ::

   p.sort_stats('time', 'cumulative').print_stats(.5, 'init')

이 호출은 모든 통계를 기본 키가 되는 시간과 보조키가 되는 누적 시간으로 정렬하고 통계의 일부를 인쇄한다.
자세히 설명하자면 전체 목록은 원래 목록에서 50%로 추려지고 (인수: ``.5``) ``init``\ 을 포함하는 행만이 남는다.
마지막으로 남은 목록이 인쇄된다.

위 함수 중 어떤 함수가 호출되는지도 알 수 있다. (``p``\ 는 마지막 기준에 따라 정렬된다.) ::

   p.print_callers(.5, 'init')

위 호출로 나열된 각 함수의 호출기 목록을 볼 수 있다.

더 많은 기능을 원한다면 매뉴얼을 읽어보거나 다음 함수가 하는 일에 대해서 알아본다. ::

   p.print_callees()
   p.add('restats')

스크립트로 호출되는 :mod:`pstats` 모듈은 프로파일 덤프를 읽고 조사하는 통계 브라우저다.
이 모듈은 :mod:`cmd`\ 를 사용해 구현된 간단한 행 지향 인터페이스와 대화형 인터페이스를 갖는다.

:mod:`profile`, :mod:`cProfile` 모듈 레퍼런스
=======================================================

.. module:: cProfile
.. module:: profile
   :synopsis: Python source profiler.

:mod:`profile`\ 과 :mod:`cProfile` 모듈은 모두 다음 함수를 제공한다.

.. function:: run(command, filename=None, sort=-1)

   이 함수는 :func:`exec` 함수로 보내질 수 있는 단일 인수와 선택 인수 파일명을 인수로 받는다.
   모든 경우에 이 루틴은 다음을 실행한다. ::

      exec(command, __main__.__dict__, __main__.__dict__)

   실행에서 프로파일링 통계를 모은다. ``filename`` 인수가 없으면 함수는 자동으로 :class:`~pstats.Stats`
   인스턴스를 생성하고 간단한 프로파일링 리포트를 인쇄한다. ``sort`` 인수가 지정되면 :class:`~pstats.Stats`
   인스턴스로 보내져 결과값을 정렬하는 방법을 결정한다. ::

.. function:: runctx(command, globals, locals, filename=None, sort=-1)

이 함수는 :func:`run` 함수와 비슷하지만 *command* 문자열을 위한 전역, 지역 딕셔너리를 제공하는 인수가 추가되어 있다.
   이 루틴은 다음을 실행한다. ::

      exec(command, globals, locals)

   :func:`run` 함수를 실행한 것처럼 프로파일링 통계를 수집한다.

.. class:: Profile(timer=None, timeunit=0.0, subcalls=True, builtins=True)

   이 클래스는 일반적으로 :func:`cProfile.run` 함수가 제공하는 것보다 더 정밀하게 프로파일링을 제어해야 할 때에만 사용된다.

   코드가 실행되는데 필요한 시간을 측정하기 위한 커스텀 타이머를 *timer* 인수에 줄 수 있다.
   이 타이머는 반드시 현재 시간을 나타내는 하나의 숫자만을 반환하는 함수가 되어야 한다.
   숫자가 정수면 *timeunit* 인수는 시간의 각 단위가 갖는 지속 시간을 지정하는 승수를 지정한다.
   예를 들어, 타이머가 천 초 단위로 측정되는 시간을 반환하면 *timeunit*은 ``.001``\ 가 된다.

   :class:`Profile` 클래스를 직접 사용하면 프로파일 데이터를 파일에 작성하지 않고 프로파일 결과를 포매팅할 수 있다. ::

      import cProfile, pstats, io
      pr = cProfile.Profile()
      pr.enable()
      # ... do something ...
      pr.disable()
      s = io.StringIO()
      sortby = 'cumulative'
      ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
      ps.print_stats()
      print(s.getvalue())

   .. method:: enable()

      프로파일링 데이터 수집을 시작한다.

   .. method:: disable()

      프로파일링 데이터 수집을 중단한다.

   .. method:: create_stats()

      프로파일링 데이터 수집을 중단하고 결과를 현재 프로파일로 내부에 기록한다.

   .. method:: print_stats(sort=-1)

      현재 프로파일에 기반해 :class:`~pstats.Stats` 객체를 생성하고 stdout으로 결과를 인쇄한다.

   .. method:: dump_stats(filename)

      현재 프로파일 결과를 *filename*에 작성한다.

   .. method:: run(cmd)

      cmd를 :func:`exec`\ 를 통해 명령을 프로파일링한다.

   .. method:: runctx(cmd, globals, locals)

      cmd를 지정된 전역, 지역 변수로 :func:`exec` \ 를 통해 프로파일링한다.

   .. method:: runcall(func, *args, **kwargs)

      ``func(*args, **kwargs)``\ 를 프로파일링 한다.

.. _profile-stats:

:class:`Stats` 클래스
========================

프로파일러 데이터 분석은 :class:`~pstats.Stats` 클래스를 사용해 이루어진다.

.. module:: pstats
   :synopsis: 프로파일러와 사용하기 위한 통계 객체.

.. class:: Stats(*filenames or profile, stream=sys.stdout)

   이 클래스 생성자는 *filename* 또는 *filename* 리스트나 :class:`Profile` 인스턴스로부터
   "통계 객체" 인스턴스를 생성한다. 출력은 *stream*에 지정된 스트림에 인쇄된다.

   위 생성자에 의해 선택된 파일은 반드시 호환되는 버전의 :mod:`profile`\ 이나
   :mod:`cProfile`\ 에 의해 생성되어야 한다. 명확히 하자면 프로파일러의 향후
   버전과의 파일 호환성은 보장되지 않고 서로 다른 프로파일러에 의해 생성된 파일들은
   호환되지 않는다. 여러 파일이 제공되면 동일한 함수를 위한 모든 통계는 병합되어
   여러 프로세스에 대한 보고가 하나의 리포트가 될 수 있게 한다. 기존 :class:`~pstats.Stats`
   객체에 있는 데이터와 추가 파일이 병합되어야 하면 :meth:`~pstats.Stats.add` 메서드를 사용한다.

   파일 대신 :class:`cProfile.Profile`\ 나 :class:`profile.Profile` 객체를 소스로 사용해
   프로파일 데이터를 읽을 수 있다.

   :class:`Stats` 객체는 다음 메서드를 갖는다.

   .. method:: strip_dirs()

      :class:`Stats` 클래스를 위한 이 메서드는 파일명 앞에 오는 모든 경로 정보를 삭제한다.
      출력물의 사이즈를 줄여 80 컬럼 이내로 맞출 때 유용하다. 이 메서드는 객체를 수정하기
      때문에 삭제된 정보는 손실된다. 삭제 작업을 한 후에는 객체의 항목들이 객체가 초기화 되고
      로드되었을 때처럼 임의의 순서로 정렬된 것으로 간주된다. :meth:`~pstats.Stats.strip_dirs`
      메서드로 인해 두개의 함수명이 같아지면 (같은 파일명, 같은 행에 있고 같은 함수명을 갖는 경우)
      이 두 항목에 대한 통계는 하나의 항목에 대한 통계로 합쳐진다.


   .. method:: add(*filenames)

      :class:`Stats` 클래스의 ``add`` 메서드는 추가 프로파일링 정보를 현재 프로파일링 객체에 합친다.
      인수가 지정하는 파일은 호환되는 :func:`profile.run`\ 이나 :func:`cProfile.run` 버전에 의해
      생성되어야 한다. 같은 이름 (같은 파일, 행, 이름)을 갖는 함수에 대한 통계는 자동으로 하나의 함수 통계에 합쳐진다.


   .. method:: dump_stats(filename)

      :class:`Stats` 객체에 로드된 데이터를 *filename* 인수에 지정된 파일에 저장한다.
      지정된 파일이 존재하지 않으면 생성되고 이미 있는 파일인 경우에는 덮어쓴다.
      :class:`profile.Profile`, :class:`cProfile.Profile` 클래스에 있는 같은 이름의 메서드와 동일하다.


   .. method:: sort_stats(*keys)

      이 메서드는 주어진 기준에 따라 :class:`Stats` 객체를 정렬한다.
      인수는 일반적으로 정렬 기준을 나타내는 문자열이다. (예시: ``time``, ``name``)

      하나 이상의 키가 주어지고 이전에 선택된 모든 키가 동일하면 추가 키는 두번째 정렬 기준으로 사용된다.
      예를 들어, ``sort_stats('name', 'file')``\ 는 모든 항목을 함수 이름에 따라 정렬하고 함수 이름으로
      정렬된 묶음이 파일명에 따라 정렬된다.

      약자명이 모호하지 않는 한 모든 키에 약자를 사용할 수 있다. 다음은 현재 정의된 키다.

      +------------------+----------------------+
      | Valid Arg        | Meaning              |
      +==================+======================+
      | ``'calls'``      | 호출 횟수            |
      +------------------+----------------------+
      | ``'cumulative'`` | 누적 시간            |
      +------------------+----------------------+
      | ``'cumtime'``    | 누적 시간            |
      +------------------+----------------------+
      | ``'file'``       | 파일명               |
      +------------------+----------------------+
      | ``'filename'``   | 파일명               |
      +------------------+----------------------+
      | ``'module'``     | 파일명               |
      +------------------+----------------------+
      | ``'ncalls'``     | 호출 횟수            |
      +------------------+----------------------+
      | ``'pcalls'``     | primitive 호출 횟수  |
      +------------------+----------------------+
      | ``'line'``       | 행 번호              |
      +------------------+----------------------+
      | ``'name'``       | 함수명               |
      +------------------+----------------------+
      | ``'nfl'``        | 이름/파일/행         |
      +------------------+----------------------+
      | ``'stdname'``    | 표준 이름            |
      +------------------+----------------------+
      | ``'time'``       | 인터널 타임          |
      +------------------+----------------------+
      | ``'tottime'``    | 인터널 타임          |
      +------------------+----------------------+

      통계에 대한 모든 정렬은 내림차순으로 정렬된다. (시간이 오래 걸린 것이 가장 위에 온다.)
      함수명, 파일명, 행 번호에 대한 정렬은 알파벳 기준으로 오름차순이다. ``'nfl'``\ 과 ``'stdname'``\ 의
      미묘한 차이는 표준 이름이 인쇄되는 이름으로 정렬된다는 것이다. 따라서 행번호는 이상한 방식으로 정렬된다.
      예를 들어, 행 번호 3, 20, 40은 같은 파일명을 가질 때 20, 3, 40 순서로 나타난다. 반대로 ``'nfl'``\ 은
      행 번호의 숫자를 비교해 정렬한다. 사실 ``sort_stats('nfl')``\ 는 ``sort_stats('name', 'file','line')``\ 와 같다.

      하위 호환성으로 인해 숫자 인수 ``-1``, ``0``, ``1``, ``2``\ 가 허용된다.
      각 숫자 인수는 ``'stdname'``, ``'calls'``, ``'time'``, ``'cumulative'``\ 로 해석된다.
      이러한 이전 스타일 포맷이 사용되면 숫자 인수만이 분류 키로 사용되고 추가 인수는 무시된다.

      .. For compatibility with the old profiler.


   .. method:: reverse_order()

      이 메서드는 객체 내부의 기본 목록을 반대로 정렬한다.
      기본이 되는 오름, 내림 차순은 분류 키 선택에 따라 결정된다.

      .. This method is provided primarily for compatibility with the old
profiler.


   .. method:: print_stats(*restrictions)

      이 메서드는 :func:`profile.run` 정의에 설명된 대로 리포트를 인쇄한다.

      인쇄되는 순서는 개체에 마지막으로 행해진 :meth:`~pstats.Stats.sort_stats`  작업에 기반해 결정된다.
      (:meth:`~pstats.Stats.add`, :meth:`~pstats.Stats.strip_dirs`\ 에 있는 주의 사항을 따른다.)

      인수가 주어지면 목록이 중요한 항목들만 포함하게 제한하는데 사용될 수 있다. 초기 목록은
      프로파일된 함수의 전체 집합이 된다. 각 제한 조건은 행 수를 선택하기 위한 정수, 제한할 행의
      비율을 선택하기 위한 0.0과 1.0 사이의 소수, 또는 정규 표현식으로 해석되는 문자열이 될 수 있다.
      (정규 표현식은 출력될 표준 이름을 분류한다.) 여러 제한 조건이 주어지면 순서대로 적용된다. ::

         print_stats(.1, 'foo:')

      위 예시는 목록의 상위 10% 항목으로 제한하고 이 중에 파일명이 :file:`.\*foo:`\ 를 포함하는 함수만을 출력한다. ::

         print_stats('foo:', .1)

      반대로 위 예시는 파일명이 :file:`.\*foo:`\ 를 포함하는 함수로 제한하고 여기에서 상위 10%만을 출력한다.


   .. method:: print_callers(*restrictions)

      이 메서드는 프로파일된 데이터베이스에 있는 각 함수를 호출한 모든 함수 목록을 출력한다.
      정렬 순서는 :meth:`~pstats.Stats.print_stats`\ 에 주어진 것과 동일하고 제한 조건 인수의 정의도 동일하다.
      각 호출기는 자신의 행에 리포트된다. 포맷은 통계를 만들어내는 프로파일러에 따라 조금 달라진다.

      * :mod:`profile`\ 를 사용하면 각 호출기 다음 괄호 안에 숫자가 표시되고 특정 호출이 생성된 횟수를 나타낸다.
        편의를 위해 오른쪽에 함수에 사용된 누적 시간이 괄호 없이 나타난다.

      * :mod:`cProfile`\ 을 사용하면 각 호출기 앞에 세개의 숫자가 나타난다.
        특정 호출이 생성된 횟수, 현재 함수가 이 호출기에 의해 호출된 동안 사용한 총 시간과 누적 시간.


   .. method:: print_callees(*restrictions)

      지정된 함수에 의해 호출된 모든 함수의 목록을 인쇄한다. 호출의 방향은 반대지만 (호출하는 것과 호출되는 것)
      사용되는 인수와 정렬는 :meth:`~pstats.Stats.print_callers`\ 와 동일하다.


.. _deterministic-profiling:

결정론적 프로파일링이란?
================================

:dfn:`결정론적 프로파일링`\ 이란 모든 *함수 호출* *함수 반환*, *예외* 이벤트가 모니터링되고
(사용자의 코드가 실행되는 동안) 각 이벤트 간에 정확한 시간 측정이 이루어진다는 의미다.
반대로 (이 모듈이 하지 않는) :dfn:`통계적 프로파일링`\ 이란 유효한 명령 포인터를 임의로 샘플링하고
사용되는 시간을 추정한다. 후자의 기술은 코드를 계측하지 않아도 되기 때문에 일반적으로
오버헤드가 적지만 사용되는 시간에 대한 상대적인 지표를 제공한다.

파이썬에는 실행중에 활성화되는 해석기가 있기 때문에 결정론적 프로파일링을 위해 계측된 코드가 없어도 된다.
파이썬은 자동으로 각 이벤트에 대해 :dfn:`hook`\ (선택 콜백)을 제공한다. 추가로 파이썬의 해석되는 특성으로 인해
실행에 많은 오버헤드가 가해지기 때문에 결정론적 프로파일링은 일반적인 어플리케이션에서 적은 프로세싱 오버헤드를 준다.
결과적으로 결정론적 프로파일링은 큰 비용 없이 실행 시간에 대한 폭넓은 통계를 제공한다.

호출 횟수 통계는 코드에 있는 버그나 (횟수가 이상한 경우) 인라인 확장 지점 (많은 호출 횟수가 많은 경우)을
인식하는데 사용될 수 있다. 내부 시간 통계는 주의깊게 최적화해야 하는 "핫 루프"를 인식하는데 사용될 수 있다.
누적 시간 통계는 알고리즘 선택과 관련된 높은 수준의 에러를 인식하는데 사용해야 한다.
누적 시간에 대한 특이한 처리로 알고리즘의 재귀 구현과 반복 구현을 직접 비교하기 위한 통계를 얻을 수 있다.


.. _profile-limitations:

한계점
===========

하나의 한계점은 시간 정보의 정확성이다. 결정론적 프로파일러의 정확성에 대한 근본적인 문제가 있다.
가장 분명한 제약은 내제된 "시계"가 일반적으로 약 .001초 단위로 간다는 것이다. 따라서 어떤 측정도
이 시계보다 정확할 수 없다. 만약 충분한 측정이 이루어지면 "에러"가 평균화 된다. 불행히도 이 첫번째
에러를 제거하면 두번째 에러가 나타난다.

두번째 문제는 이벤트가 보내지고 시간을 얻기 위한 프로파일러의 호출이 실제로 시계의 상태를 얻을 때까지
시간이 걸린다는 것이다. 이와 유사하게 이벤트 핸들러를 종료할 때 시계의 값이 얻어질 때부터 사용자의 코드가
다시 실행될 때까지 지연이 존재한다. 그 결과 여러번 호출되거나 많은 함수를 호출하는 함수는 일반적으로
이러한 에러를 축적한다. 이러한 방식으로 축적되는 에러는 일반적으로 시계의 정확도보다 작지만 축적되면 심각해질 수 있다.

문제는 오버헤드가 적은 :mod:`cProfile`\ 보다 :mod:`profile`\ 에서 더 중요하다. 이러한 이유로 :mod:`profile`\ 은
몇몇 플랫폼에서 보정 수단을 제공해 에러가 통계적으로(평균으로) 제거될 수 있게 한다. 프로파일러가 보정되고 나면
(최소한 제곱 센스에서) 더 정확해지지만 종종 음수를 주기도 한다. (호출 횟수가 예외적으로 낮을 때) 프로파일에
음수가 나타나도 놀라지 말자. 프로파일러를 보정했을 때만 나타나며 보정하지 않은 결과보다 정확하다.


.. _profile-calibration:

Calibration
===========

The profiler of the :mod:`profile` module subtracts a constant from each event
handling time to compensate for the overhead of calling the time function, and
socking away the results.  By default, the constant is 0. The following
procedure can be used to obtain a better constant for a given platform (see
:ref:`profile-limitations`). ::

   import profile
   pr = profile.Profile()
   for i in range(5):
       print(pr.calibrate(10000))

The method executes the number of Python calls given by the argument, directly
and again under the profiler, measuring the time for both. It then computes the
hidden overhead per profiler event, and returns that as a float.  For example,
on a 1.8Ghz Intel Core i5 running Mac OS X, and using Python's time.process_time() as
the timer, the magical number is about 4.04e-6.

The object of this exercise is to get a fairly consistent result. If your
computer is *very* fast, or your timer function has poor resolution, you might
have to pass 100000, or even 1000000, to get consistent results.

When you have a consistent answer, there are three ways you can use it::

   import profile

   # 1. Apply computed bias to all Profile instances created hereafter.
   profile.Profile.bias = your_computed_bias

   # 2. Apply computed bias to a specific Profile instance.
   pr = profile.Profile()
   pr.bias = your_computed_bias

   # 3. Specify computed bias in instance constructor.
   pr = profile.Profile(bias=your_computed_bias)

If you have a choice, you are better off choosing a smaller constant, and then
your results will "less often" show up as negative in profile statistics.

.. _profile-timers:

Using a custom timer
====================

If you want to change how current time is determined (for example, to force use
of wall-clock time or elapsed process time), pass the timing function you want
to the :class:`Profile` class constructor::

    pr = profile.Profile(your_time_func)

The resulting profiler will then call ``your_time_func``. Depending on whether
you are using :class:`profile.Profile` or :class:`cProfile.Profile`,
``your_time_func``'s return value will be interpreted differently:

:class:`profile.Profile`
   ``your_time_func`` should return a single number, or a list of numbers whose
   sum is the current time (like what :func:`os.times` returns).  If the
   function returns a single time number, or the list of returned numbers has
   length 2, then you will get an especially fast version of the dispatch
   routine.

   Be warned that you should calibrate the profiler class for the timer function
   that you choose (see :ref:`profile-calibration`).  For most machines, a timer
   that returns a lone integer value will provide the best results in terms of
   low overhead during profiling.  (:func:`os.times` is *pretty* bad, as it
   returns a tuple of floating point values).  If you want to substitute a
   better timer in the cleanest fashion, derive a class and hardwire a
   replacement dispatch method that best handles your timer call, along with the
   appropriate calibration constant.

:class:`cProfile.Profile`
   ``your_time_func`` should return a single number.  If it returns integers,
   you can also invoke the class constructor with a second argument specifying
   the real duration of one unit of time.  For example, if
   ``your_integer_time_func`` returns times measured in thousands of seconds,
   you would construct the :class:`Profile` instance as follows::

      pr = cProfile.Profile(your_integer_time_func, 0.001)

   As the :class:`cProfile.Profile` class cannot be calibrated, custom timer
   functions should be used with care and should be as fast as possible.  For
   the best results with a custom timer, it might be necessary to hard-code it
   in the C source of the internal :mod:`_lsprof` module.

Python 3.3 adds several new functions in :mod:`time` that can be used to make
precise measurements of process or wall-clock time. For example, see
:func:`time.perf_counter`.
