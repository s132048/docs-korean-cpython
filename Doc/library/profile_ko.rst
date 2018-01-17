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

The :meth:`~pstats.Stats.strip_dirs` method removed the extraneous path from all
the module names. The :meth:`~pstats.Stats.sort_stats` method sorted all the
entries according to the standard module/line/name string that is printed. The
:meth:`~pstats.Stats.print_stats` method printed out all the statistics.  You
might try the following sort calls::

   p.sort_stats('name')
   p.print_stats()

The first call will actually sort the list by function name, and the second call
will print out the statistics.  The following are some interesting calls to
experiment with::

   p.sort_stats('cumulative').print_stats(10)

This sorts the profile by cumulative time in a function, and then only prints
the ten most significant lines.  If you want to understand what algorithms are
taking time, the above line is what you would use.

If you were looking to see what functions were looping a lot, and taking a lot
of time, you would do::

   p.sort_stats('time').print_stats(10)

to sort according to time spent within each function, and then print the
statistics for the top ten functions.

You might also try::

   p.sort_stats('file').print_stats('__init__')

This will sort all the statistics by file name, and then print out statistics
for only the class init methods (since they are spelled with ``__init__`` in
them).  As one final example, you could try::

   p.sort_stats('time', 'cumulative').print_stats(.5, 'init')

This line sorts statistics with a primary key of time, and a secondary key of
cumulative time, and then prints out some of the statistics. To be specific, the
list is first culled down to 50% (re: ``.5``) of its original size, then only
lines containing ``init`` are maintained, and that sub-sub-list is printed.

If you wondered what functions called the above functions, you could now (``p``
is still sorted according to the last criteria) do::

   p.print_callers(.5, 'init')

and you would get a list of callers for each of the listed functions.

If you want more functionality, you're going to have to read the manual, or
guess what the following functions do::

   p.print_callees()
   p.add('restats')

Invoked as a script, the :mod:`pstats` module is a statistics browser for
reading and examining profile dumps.  It has a simple line-oriented interface
(implemented using :mod:`cmd`) and interactive help.

:mod:`profile` and :mod:`cProfile` Module Reference
=======================================================

.. module:: cProfile
.. module:: profile
   :synopsis: Python source profiler.

Both the :mod:`profile` and :mod:`cProfile` modules provide the following
functions:

.. function:: run(command, filename=None, sort=-1)

   This function takes a single argument that can be passed to the :func:`exec`
   function, and an optional file name.  In all cases this routine executes::

      exec(command, __main__.__dict__, __main__.__dict__)

   and gathers profiling statistics from the execution. If no file name is
   present, then this function automatically creates a :class:`~pstats.Stats`
   instance and prints a simple profiling report. If the sort value is specified,
   it is passed to this :class:`~pstats.Stats` instance to control how the
   results are sorted.

.. function:: runctx(command, globals, locals, filename=None, sort=-1)

   This function is similar to :func:`run`, with added arguments to supply the
   globals and locals dictionaries for the *command* string. This routine
   executes::

      exec(command, globals, locals)

   and gathers profiling statistics as in the :func:`run` function above.

.. class:: Profile(timer=None, timeunit=0.0, subcalls=True, builtins=True)

   This class is normally only used if more precise control over profiling is
   needed than what the :func:`cProfile.run` function provides.

   A custom timer can be supplied for measuring how long code takes to run via
   the *timer* argument. This must be a function that returns a single number
   representing the current time. If the number is an integer, the *timeunit*
   specifies a multiplier that specifies the duration of each unit of time. For
   example, if the timer returns times measured in thousands of seconds, the
   time unit would be ``.001``.

   Directly using the :class:`Profile` class allows formatting profile results
   without writing the profile data to a file::

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

      Start collecting profiling data.

   .. method:: disable()

      Stop collecting profiling data.

   .. method:: create_stats()

      Stop collecting profiling data and record the results internally
      as the current profile.

   .. method:: print_stats(sort=-1)

      Create a :class:`~pstats.Stats` object based on the current
      profile and print the results to stdout.

   .. method:: dump_stats(filename)

      Write the results of the current profile to *filename*.

   .. method:: run(cmd)

      Profile the cmd via :func:`exec`.

   .. method:: runctx(cmd, globals, locals)

      Profile the cmd via :func:`exec` with the specified global and
      local environment.

   .. method:: runcall(func, *args, **kwargs)

      Profile ``func(*args, **kwargs)``

.. _profile-stats:

The :class:`Stats` Class
========================

Analysis of the profiler data is done using the :class:`~pstats.Stats` class.

.. module:: pstats
   :synopsis: Statistics object for use with the profiler.

.. class:: Stats(*filenames or profile, stream=sys.stdout)

   This class constructor creates an instance of a "statistics object" from a
   *filename* (or list of filenames) or from a :class:`Profile` instance. Output
   will be printed to the stream specified by *stream*.

   The file selected by the above constructor must have been created by the
   corresponding version of :mod:`profile` or :mod:`cProfile`.  To be specific,
   there is *no* file compatibility guaranteed with future versions of this
   profiler, and there is no compatibility with files produced by other
   profilers.  If several files are provided, all the statistics for identical
   functions will be coalesced, so that an overall view of several processes can
   be considered in a single report.  If additional files need to be combined
   with data in an existing :class:`~pstats.Stats` object, the
   :meth:`~pstats.Stats.add` method can be used.

   Instead of reading the profile data from a file, a :class:`cProfile.Profile`
   or :class:`profile.Profile` object can be used as the profile data source.

   :class:`Stats` objects have the following methods:

   .. method:: strip_dirs()

      This method for the :class:`Stats` class removes all leading path
      information from file names.  It is very useful in reducing the size of
      the printout to fit within (close to) 80 columns.  This method modifies
      the object, and the stripped information is lost.  After performing a
      strip operation, the object is considered to have its entries in a
      "random" order, as it was just after object initialization and loading.
      If :meth:`~pstats.Stats.strip_dirs` causes two function names to be
      indistinguishable (they are on the same line of the same filename, and
      have the same function name), then the statistics for these two entries
      are accumulated into a single entry.


   .. method:: add(*filenames)

      This method of the :class:`Stats` class accumulates additional profiling
      information into the current profiling object.  Its arguments should refer
      to filenames created by the corresponding version of :func:`profile.run`
      or :func:`cProfile.run`. Statistics for identically named (re: file, line,
      name) functions are automatically accumulated into single function
      statistics.


   .. method:: dump_stats(filename)

      Save the data loaded into the :class:`Stats` object to a file named
      *filename*.  The file is created if it does not exist, and is overwritten
      if it already exists.  This is equivalent to the method of the same name
      on the :class:`profile.Profile` and :class:`cProfile.Profile` classes.


   .. method:: sort_stats(*keys)

      This method modifies the :class:`Stats` object by sorting it according to
      the supplied criteria.  The argument is typically a string identifying the
      basis of a sort (example: ``'time'`` or ``'name'``).

      When more than one key is provided, then additional keys are used as
      secondary criteria when there is equality in all keys selected before
      them.  For example, ``sort_stats('name', 'file')`` will sort all the
      entries according to their function name, and resolve all ties (identical
      function names) by sorting by file name.

      Abbreviations can be used for any key names, as long as the abbreviation
      is unambiguous.  The following are the keys currently defined:

      +------------------+----------------------+
      | Valid Arg        | Meaning              |
      +==================+======================+
      | ``'calls'``      | call count           |
      +------------------+----------------------+
      | ``'cumulative'`` | cumulative time      |
      +------------------+----------------------+
      | ``'cumtime'``    | cumulative time      |
      +------------------+----------------------+
      | ``'file'``       | file name            |
      +------------------+----------------------+
      | ``'filename'``   | file name            |
      +------------------+----------------------+
      | ``'module'``     | file name            |
      +------------------+----------------------+
      | ``'ncalls'``     | call count           |
      +------------------+----------------------+
      | ``'pcalls'``     | primitive call count |
      +------------------+----------------------+
      | ``'line'``       | line number          |
      +------------------+----------------------+
      | ``'name'``       | function name        |
      +------------------+----------------------+
      | ``'nfl'``        | name/file/line       |
      +------------------+----------------------+
      | ``'stdname'``    | standard name        |
      +------------------+----------------------+
      | ``'time'``       | internal time        |
      +------------------+----------------------+
      | ``'tottime'``    | internal time        |
      +------------------+----------------------+

      Note that all sorts on statistics are in descending order (placing most
      time consuming items first), where as name, file, and line number searches
      are in ascending order (alphabetical). The subtle distinction between
      ``'nfl'`` and ``'stdname'`` is that the standard name is a sort of the
      name as printed, which means that the embedded line numbers get compared
      in an odd way.  For example, lines 3, 20, and 40 would (if the file names
      were the same) appear in the string order 20, 3 and 40.  In contrast,
      ``'nfl'`` does a numeric compare of the line numbers.  In fact,
      ``sort_stats('nfl')`` is the same as ``sort_stats('name', 'file',
      'line')``.

      For backward-compatibility reasons, the numeric arguments ``-1``, ``0``,
      ``1``, and ``2`` are permitted.  They are interpreted as ``'stdname'``,
      ``'calls'``, ``'time'``, and ``'cumulative'`` respectively.  If this old
      style format (numeric) is used, only one sort key (the numeric key) will
      be used, and additional arguments will be silently ignored.

      .. For compatibility with the old profiler.


   .. method:: reverse_order()

      This method for the :class:`Stats` class reverses the ordering of the
      basic list within the object.  Note that by default ascending vs
      descending order is properly selected based on the sort key of choice.

      .. This method is provided primarily for compatibility with the old
         profiler.


   .. method:: print_stats(*restrictions)

      This method for the :class:`Stats` class prints out a report as described
      in the :func:`profile.run` definition.

      The order of the printing is based on the last
      :meth:`~pstats.Stats.sort_stats` operation done on the object (subject to
      caveats in :meth:`~pstats.Stats.add` and
      :meth:`~pstats.Stats.strip_dirs`).

      The arguments provided (if any) can be used to limit the list down to the
      significant entries.  Initially, the list is taken to be the complete set
      of profiled functions.  Each restriction is either an integer (to select a
      count of lines), or a decimal fraction between 0.0 and 1.0 inclusive (to
      select a percentage of lines), or a string that will interpreted as a
      regular expression (to pattern match the standard name that is printed).
      If several restrictions are provided, then they are applied sequentially.
      For example::

         print_stats(.1, 'foo:')

      would first limit the printing to first 10% of list, and then only print
      functions that were part of filename :file:`.\*foo:`.  In contrast, the
      command::

         print_stats('foo:', .1)

      would limit the list to all functions having file names :file:`.\*foo:`,
      and then proceed to only print the first 10% of them.


   .. method:: print_callers(*restrictions)

      This method for the :class:`Stats` class prints a list of all functions
      that called each function in the profiled database.  The ordering is
      identical to that provided by :meth:`~pstats.Stats.print_stats`, and the
      definition of the restricting argument is also identical.  Each caller is
      reported on its own line.  The format differs slightly depending on the
      profiler that produced the stats:

      * With :mod:`profile`, a number is shown in parentheses after each caller
        to show how many times this specific call was made.  For convenience, a
        second non-parenthesized number repeats the cumulative time spent in the
        function at the right.

      * With :mod:`cProfile`, each caller is preceded by three numbers: the
        number of times this specific call was made, and the total and
        cumulative times spent in the current function while it was invoked by
        this specific caller.


   .. method:: print_callees(*restrictions)

      This method for the :class:`Stats` class prints a list of all function
      that were called by the indicated function.  Aside from this reversal of
      direction of calls (re: called vs was called by), the arguments and
      ordering are identical to the :meth:`~pstats.Stats.print_callers` method.


.. _deterministic-profiling:

What Is 결정론적 프로파일링?
================================

:dfn:`결정론적 프로파일링` is meant to reflect the fact that all *function
call*, *function return*, and *exception* events are monitored, and precise
timings are made for the intervals between these events (during which time the
user's code is executing).  In contrast, :dfn:`statistical profiling` (which is
not done by this module) randomly samples the effective instruction pointer, and
deduces where time is being spent.  The latter technique traditionally involves
less overhead (as the code does not need to be instrumented), but provides only
relative indications of where time is being spent.

In Python, since there is an interpreter active during execution, the presence
of instrumented code is not required to do 결정론적 프로파일링.  Python
automatically provides a :dfn:`hook` (optional callback) for each event.  In
addition, the interpreted nature of Python tends to add so much overhead to
execution, that 결정론적 프로파일링 tends to only add small processing
overhead in typical applications.  The result is that 결정론적 프로파일링 is
not that expensive, yet provides extensive run time statistics about the
execution of a Python program.

Call count statistics can be used to identify bugs in code (surprising counts),
and to identify possible inline-expansion points (high call counts).  Internal
time statistics can be used to identify "hot loops" that should be carefully
optimized.  Cumulative time statistics should be used to identify high level
errors in the selection of algorithms.  Note that the unusual handling of
cumulative times in this profiler allows statistics for recursive
implementations of algorithms to be directly compared to iterative
implementations.


.. _profile-limitations:

Limitations
===========

One limitation has to do with accuracy of timing information. There is a
fundamental problem with deterministic profilers involving accuracy.  The most
obvious restriction is that the underlying "clock" is only ticking at a rate
(typically) of about .001 seconds.  Hence no measurements will be more accurate
than the underlying clock.  If enough measurements are taken, then the "error"
will tend to average out. Unfortunately, removing this first error induces a
second source of error.

The second problem is that it "takes a while" from when an event is dispatched
until the profiler's call to get the time actually *gets* the state of the
clock.  Similarly, there is a certain lag when exiting the profiler event
handler from the time that the clock's value was obtained (and then squirreled
away), until the user's code is once again executing.  As a result, functions
that are called many times, or call many functions, will typically accumulate
this error. The error that accumulates in this fashion is typically less than
the accuracy of the clock (less than one clock tick), but it *can* accumulate
and become very significant.

The problem is more important with :mod:`profile` than with the lower-overhead
:mod:`cProfile`.  For this reason, :mod:`profile` provides a means of
calibrating itself for a given platform so that this error can be
probabilistically (on the average) removed. After the profiler is calibrated, it
will be more accurate (in a least square sense), but it will sometimes produce
negative numbers (when call counts are exceptionally low, and the gods of
probability work against you :-). )  Do *not* be alarmed by negative numbers in
the profile.  They should *only* appear if you have calibrated your profiler,
and the results are actually better than without calibration.


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
