:mod:`logging` --- 파이썬 로그 기능
==============================================

.. module:: logging
   :synopsis: Flexible event logging system for applications.

.. moduleauthor:: Vinay Sajip <vinay_sajip@red-dove.com>
.. sectionauthor:: Vinay Sajip <vinay_sajip@red-dove.com>

**Source code:** :source:`Lib/logging/__init__.py`

.. index:: pair: Errors; logging

.. sidebar:: Important

   이 페이지는 API 참조 정보만 포함한다.
   튜토리얼 정보와 더 고급 주제는 다음을 참조한다.

   * :ref:`기초 튜토리얼 <logging-basic-tutorial>`
   * :ref:`고급 튜토리얼 <logging-advanced-tutorial>`
   * :ref:`로그 쿡북 <logging-cookbook>`

--------------

이 모듈은 애플리케이션과 라이브러리에서 사용할 수 있는 유연한 이벤트 로그 시스템을 구현한
함수와 클래스를 정의한다.

표준 라이브러리 모듈에서 제공하는 로그 API의 장점은
모든 파이썬 모듈에서 로그에 참여할 수 있어서 애플리케이션 로그가
써드 파티 모듈로부터의 메세지와 직접 만든 메세지를 모두 포함할 수 있다는 점이다.

이 모듈은 많은 기능과 유연성을 제공한다.
만약 로그에 익숙하지 않다면 익숙해지는 최고의 방법은 튜토리얼을 읽는 것이다.
(우측 링크를 참조한다.)

이 모듈에서 정의된 기초 클래스와 함수는 다음과 같다.

* 애플리케이션 코드에서 직접 사용할 수 있는 인터페이스를 가진 로거(logger)
* (로거가 생성한) 로그 레코드를 적절한 목적지로 보내는 핸들러(handler)
* 어떤 로그 레코드를 출력할지 결정하는 세밀한 기능을 제공하는 필터(filter)
* 최종 출력에서의 로그 레코드의 레이아웃을 결정하는 포매터(formatter)


.. _logger:

로거(Logger) 객체
-----------------------------------

로거는 다음 속성과 메서드를 가진다.
로거 인스턴스는 직접 생성하지 않고 모듈레벨 함수인 ``logging.getLogger(name)``\ 를 이용한다.
:func:`getLogger` 함수는 같은 이름으로 여러번 호출해도 동일한 로거 객체에 대한 참조를 반환한다.

``name`` 인수는 ``foo.bar.baz``\ 처럼 마침표(period)를 포함하는 계층적인 문자열을 쓸 수 있다.
(물론 그냥 ``foo``\ 라고 써도 된다.)
계층적 리스트에서 뒷쪽(하위)에 있는 로거는 앞쪽(상위)의 로거의 자식 로거가 된다.
예를 들어 ``foo``\ 라는 로거가 있으면 ``foo.bar``, ``foo.bar.baz``, ``foo.bam``\ 는
모두 ``foo`` 로거의 자식 로거이다.
로거 이름의 계층 구조는 파이썬 패키지 구조와 유사하다.
``logging.getLogger(__name__)`` 코드를 이용하여 로거를 만들면
``__name__``\ 가 파이썬 패키지 이름 공간에서 모듈의 이름이 되기 때문에
파이썬 패키지와 완전히 동일한 로거 구조가 만들어진다.


.. class:: Logger

   .. attribute:: Logger.propagate

      이 속성값이 참이면 이 로거에 기록된 이벤트는 상위 레벨(조상) 로거의 핸들러나 연결된 모든 핸들러로
      전달된다. 메세지는 조상 로거의 핸들러로 직접 전달된다. 조상 로거의 레벨이나 필터는 상관하지 않는다.

      만약 이 속성값이 거짓이면 로깅 메세지는 조상 로거의 핸들러에 전달되지 않는다.

      이 속성은 생성자에서 ``True``\ 으로 설정된다.

      .. note:: 같은 핸들러를 어떤 로거와 그 조상 로거에 동시에 붙이면 같은 레코드를 여러번 받을 수 있다.
         일반적으로 핸들러는 두 개 이상의 로거에 붙이지 않는다.
         핸들러를 로거 계층 상의 어떤 상위 로거에 붙이면 propagate 설정이 ``True``\ 인 한,
         모든 하위 로거의 이벤트는 모두 볼 수 있다.
         일반적으로는 핸들러를 루트 로거에만 붙이고 다른 로거가 propagate하도록 한다.

   .. method:: Logger.setLevel(lvl)

      로거의 레벨 설정값을 *lvl*\ 로 지정한다. *lvl*\ 보다 덜 중요한 로깅 메세지는 무시된다.
      중요도(severity)가 *lvl*\ 과 같거나 큰 로깅 메세지만 이 로거를 담당하는 핸들러에서 처리된다.
      핸들러의 레벨이 *lvl*\ 보다 높으면 처리되지 않는다.

      로거를 생성할 때 레벨은 :const:`NOTSET`\ 로 설정된다. (이렇게 하면
      로거가 루트 로거일 때 모든 메세지가 처리된다.)
      루트 로거는 :const:`WARNING` 레벨로 생성된다는 점에 유의한다.

      원문: When a logger is created, the level is set to :const:`NOTSET` (which causes
      all messages to be processed when the logger is the root logger, or delegation
      to the parent when the logger is a non-root logger). Note that the root logger
      is created with level :const:`WARNING`.

      어떤 로거가 NOTSET 레벨이고 그 조상 로거들을 거슬러 올라가면서 레벨이 NOTSET이 아닌
      조상 로거를 만나거나 루트 로거를 만나기 전까지의 조상 로거들을 delegation이라고 한다.

      만약 NOTSET 레벨이 아닌 조상 로거를 발견하면 그 조상 로거의 레벨이 해당 로거의 실질적인
      레벨이 되고 로깅 이벤트를 처리하는 기준이 된다.

      만약 루트 로거까지 거슬러 올라가게 되었는데 루트 로거의 레벨이 NOTSET이면 모든 메세지가 처리된다.
      레벨이 NOTSET이 아니면 루트 로거의 레벨이 실질 레벨로 사용된다.

      레벨 목록은 :ref:`levels`\ 을 참조한다.

      .. versionchanged:: 3.2
         *lvl* 파라미터로 :const:`INFO`\ 에 해당하는 정수 상수 대신 문자열 'INFO'\ 를 쓸 수 있다.
         하지만 내부적으로는 정수로 저장되며 :meth:`getEffectiveLevel`, :meth:`isEnabledFor` 메서드 등은
         여전히 정수 인수를 반환하거나 받는다는 점에 주의 한다.

   .. method:: Logger.isEnabledFor(lvl)

      이 로거가 중요도 레벨이 *lvl*\ 인 메세지를 처리할 수 있는지 여부.
      ``logging.disable(lvl)``\ 로 설정된 모듈수준에서의 레벨을 우선 확인하고
      :meth:`getEffectiveLevel`\ 로 실질 리벨을 확인한다.

   .. method:: Logger.getEffectiveLevel()

      이 로거의 실질 레벨을 가리킨다. 만약 :meth:`setLevel`\ 로 :const:`NOTSET`\ 이 아닌 값이 설정되었으면
      그 값을 반환한다.
      그렇지 않으면 루트 로거까지 상위 로거를 추적하여 :const:`NOTSET`\ 이 아닌 값을 찾아서 반환한다.
      반환되는 값은 정수이며 보통 :const:`logging.DEBUG`, :const:`logging.INFO` 등이다.

   .. method:: Logger.getChild(suffix)

      이 로거의 자손 로거 중에서 suffix를 가진 로거를 반환한다.
      예를 들어 ``logging.getLogger('abc').getChild('def.ghi')`` 명령은
      ``logging.getLogger('abc.def.ghi')`` 명령과 같은 로거를 반환한다.
      부모 로거의 이름이 ``__name__``\ 처럼 리터럴 문자열이 아닐 때 편리하다.

      .. versionadded:: 3.2

   .. method:: Logger.debug(msg, *args, **kwargs)

      :const:`DEBUG` 레벨의 메세지를 기록한다. *msg*\ 는 메세지 형식의 문자열이고
      *args*\ 는 문자열 형식화 연산자를 사용하여 *msg*\ 와 결합될 수 있는 인수들이다.
      (따라서 딕셔너리 자료형의 인수와 키워드를 사용하는 형식화 문자열도 쓸 수 있다.)

      *kwargs*\ 에는 *exc_info*, *stack_info*,  *extra*\ 라는 세 가지 키워드 인수를 사용한다.

      *exc_info*\ 가 거짓이 아니면 로그 메세지에 예외 정보가 추가된다.
      만약 (:func:`sys.exc_info`\ 가 반환하는 형식의) 예외 튜플 또는 예외 인스턴스가 주어지면
      이를 직접 사용하고 그렇지 않으면 예외 정보를 얻기 위해 :func:`sys.exc_info`\ 를 호출한다.

      두번째 키워드 인수인 *stack_info*\ 는 디폴트로 ``False`` 값을 가진다.
      만약 이 값이 참이면 로그 메세지에 실제 로그 호출을 포함한 스택 정보가 더해진다.
      이 정보는 *exc_info*\ 를 지정했을 때 표시되는 스택 정보와는 다르다.
      *exc_info*\ 를 지정한 경우에는 현재 쓰레드에서 스택의 바닥부터 로그 호출까지의 정보이지만
      *stack_info*\ 는 예외 핸들러를 찾으면서 나온 예외들을 말한다.

      원문: The
      former is stack frames from the bottom of the stack up to the logging call
      in the current thread, whereas the latter is information about stack frames
      which have been unwound, following an exception, while searching for
      exception handlers.

      *stack_info*\ 와 *exc_info*\ 는 각각 독립적으로 설정할 수 있으므로
      심지어는 예외가 발생하지 않은 경우에도
      코드의 특정 부분을 보여줄 수 있다.
      스택프레임이 인쇄될 때는 첫머리에 다음과 같이 나온다.::

          Stack (most recent call last):

      이것은 예외 프레임을 표시할 때 나오는 ``Traceback (most recent call last):``\ 를
      흉내낸 것이다.

      세번쩨 키워드 인수인 *extra*\ 는 LogRecord의 __dict__ 딕셔너리를 만드는 정보를
      딕셔너리로 넘겨 사용자가 정의한 속성을 가진 로그 이벤트를 만들 수 있다.
      이런 사용자 지정 속성은 로그 메세지와 결합되어 여러가지로 쓰일 수 있다. 예를 들어::

         FORMAT = '%(asctime)-15s %(clientip)s %(user)-8s %(message)s'
         logging.basicConfig(format=FORMAT)
         d = {'clientip': '192.168.0.1', 'user': 'fbloggs'}
         logger = logging.getLogger('tcpserver')
         logger.warning('Protocol problem: %s', 'connection reset', extra=d)

      는 다음과 같은 메세지를 출력한다.::

         2006-02-08 22:20:02,165 192.168.0.1 fbloggs  Protocol problem: connection reset

      *extra*\ 로 넘기는 딕셔너리의 키는 로그 시스템에서 사용하는 키와 충돌하지 않아야 한다.
      (로그 시스템에서 쓰이는 키에 대해서는 :class:`Formatter` 참조.)

      만약 이 속성들을 로그 메세지에 사용하기로 했다면 주의를 기울여야 한다.
      예를 드렁 위의 예제 코드에서 :class:`Formatter`\ 는
      LogRecord의 속성 딕셔너리 중 'clientip', 'user'\ 를 사용하여 문자열을 만드는 것으로
      되어 있다.
      만약 이 값들이 없으면 문자열 형식화 예외가 발생해서 전체 메세지가 기록되지 않는다.
      따라서 이때는 항상 *extra* 딕셔너리 값에 이 키들을 넣어서 전달해야 한다.

      이게 귀찮을 수도 있지만
      이 기능은 코드가 복수의 컨텍스트에서 실행되는 멀티쓰레드 서버라든가
      (리모트 IP 주소와 인증된 사용자 이름 등과 같이) 컨텍스트 의존적인 조건을
      다루는 특수한 경우를 위해 만들어진 기능이다.
      이런 경우에는 보통 특별한 :class:`Formatter`\ 들을 :class:`Handler`\ 와 같이
      사용한다.

      .. versionadded:: 3.2
         *stack_info* 파라미터 추가.

      .. versionchanged:: 3.5
         *exc_info* 파라미터가 예외 인스턴스를 받을 수 있음.


   .. method:: Logger.info(msg, *args, **kwargs)

      :const:`INFO` 레벨로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.


   .. method:: Logger.warning(msg, *args, **kwargs)

      :const:`WARNING` 레벨로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.

      .. note:: 과거에는 ``warning``\ 과 같은 의미의 ``warn`` 메서드가 있었으나 퇴출되었다.
         ``warning`` 메서드를 사용하라.

   .. method:: Logger.error(msg, *args, **kwargs)

      :const:`ERROR` 레벨로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.


   .. method:: Logger.critical(msg, *args, **kwargs)

      :const:`CRITICAL` 레벨로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.


   .. method:: Logger.log(lvl, msg, *args, **kwargs)

      정수 레벨 *lvl*\ 로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.


   .. method:: Logger.exception(msg, *args, **kwargs)

      :const:`ERROR` 레벨로 메세지를 로깅한다. 인수는 :meth:`debug`\ 와 같다.
      에외 정보가 로그 메세지에 더해진다.
      이 메서드는 예외 핸들러에서만 호출해야 한다.


   .. method:: Logger.addFilter(filt)

      필터 *filt*\ 를 로거에 추가한다.


   .. method:: Logger.removeFilter(filt)

      필터 *filt*\ 를 로거에서 제거한다.


   .. method:: Logger.filter(record)

      로거의 필터에 레코드를 적용하고 만약 레코드가 처리되면 참 값을 반환한다.
      필터는 거짓 값이 나올 때까지 차례대로 적용된다.
      만약 거짓 값을 반환하는 필터가 없으면 처리가 끝나고 핸들러로 전송된다.
      필터 중 하나라도 거짓 값을 반환하면 레코드가 처리되지 않는다.


   .. method:: Logger.addHandler(hdlr)

      핸들러 *hdlr*\ 를 로거에 추가한다.


   .. method:: Logger.removeHandler(hdlr)

      핸들러 *hdlr*\ 를 로거에서 제거한다.


   .. method:: Logger.findCaller(stack_info=False)

      호출 함수의 소스 파일 이름과 행 번호를 찾는다.
      파일 이름, 행 번호, 함수 이름, 스택 정보를 4-원소 튜플로 반환한다.
      *stack_info*\ 가 ``True``\ 가 아니면 스택 정보는 ``None``\ 을 반환한다.


   .. method:: Logger.handle(record)

      레코드를 해당 로거와 (*propagate* 값이 거짓인 로그를 찾을 때까지) 그 조상 로거에
      연결된 모든 핸들러에게 전달한다.
      이 메서드는 레코드를 소켓에서 받아 pickle 직렬화가 어렵거나 지역적으로 생성되었을 때
      사용된다.
      :meth:`~Logger.filter`\ 을 사용한 로거 레벨 필터링이 적용된다.


   .. method:: Logger.makeRecord(name, lvl, fn, lno, msg, args, exc_info, func=None, extra=None, sinfo=None)

      특수한 :class:`LogRecord` 인스턴스를 생성하기 위해 서브클래스에 오버라이된 팩토리 메서드


   .. method:: Logger.hasHandlers()

      로거가 설정이 완료된 핸들러를 가지고 있는지 확인한다.
      로거와 로거 계층 상의 모든 부모 로그를 확인한다.
      만약 핸들러를 발견하면 ``True``\ 를 반환하고 그렇지 않으면 ``False``\ 를 반환한다.
      로그 계층 탐색 중에 어떤 로그의 'propagate' 속성이 거짓이면 탐색이 중지된다.
      핸들러가 있는지 없는지는 따라서 그 로그까지만 확인된다.

      .. versionadded:: 3.2

   .. versionchanged:: 3.7
      로거도 pickle 직렬화할 수 있다.

.. _levels:

로깅 레벨
--------------

로그 레벨에 대한 수치 값을 다음 표에 나타내었다.
자체적인 로그 레벨을 정의하고 미리 정해진 레벨 대비 상대적인 중요도를 정하고 싶을 때 유용하다.
만약 기존의 수치 값과 같은 레벨을 정의 하면 기존의 레벨을 덮어쓰므로 기존의 레벨 이름이 없어진다.


+--------------+---------------+
| Level        | Numeric value |
+==============+===============+
| ``CRITICAL`` | 50            |
+--------------+---------------+
| ``ERROR``    | 40            |
+--------------+---------------+
| ``WARNING``  | 30            |
+--------------+---------------+
| ``INFO``     | 20            |
+--------------+---------------+
| ``DEBUG``    | 10            |
+--------------+---------------+
| ``NOTSET``   | 0             |
+--------------+---------------+


.. _handler:

핸들러(Handler) 객체
--------------------------------------

Handlers have the following attributes and methods. Note that :class:`Handler`
is never instantiated directly; this class acts as a base for more useful
subclasses. However, the :meth:`__init__` method in subclasses needs to call
:meth:`Handler.__init__`.

.. class:: Handler

   .. method:: Handler.__init__(level=NOTSET)

      Initializes the :class:`Handler` instance by setting its level, setting the list
      of filters to the empty list and creating a lock (using :meth:`createLock`) for
      serializing access to an I/O mechanism.


   .. method:: Handler.createLock()

      Initializes a thread lock which can be used to serialize access to underlying
      I/O functionality which may not be threadsafe.


   .. method:: Handler.acquire()

      Acquires the thread lock created with :meth:`createLock`.


   .. method:: Handler.release()

      Releases the thread lock acquired with :meth:`acquire`.


   .. method:: Handler.setLevel(lvl)

      Sets the threshold for this handler to *lvl*. Logging messages which are less
      severe than *lvl* will be ignored. When a handler is created, the level is set
      to :const:`NOTSET` (which causes all messages to be processed).

      See :ref:`levels` for a list of levels.

      .. versionchanged:: 3.2
         The *lvl* parameter now accepts a string representation of the
         level such as 'INFO' as an alternative to the integer constants
         such as :const:`INFO`.


   .. method:: Handler.setFormatter(form)

      Sets the :class:`Formatter` for this handler to *form*.


   .. method:: Handler.addFilter(filt)

      Adds the specified filter *filt* to this handler.


   .. method:: Handler.removeFilter(filt)

      Removes the specified filter *filt* from this handler.


   .. method:: Handler.filter(record)

      Applies this handler's filters to the record and returns a true value if the
      record is to be processed. The filters are consulted in turn, until one of
      them returns a false value. If none of them return a false value, the record
      will be emitted. If one returns a false value, the handler will not emit the
      record.


   .. method:: Handler.flush()

      Ensure all logging output has been flushed. This version does nothing and is
      intended to be implemented by subclasses.


   .. method:: Handler.close()

      Tidy up any resources used by the handler. This version does no output but
      removes the handler from an internal list of handlers which is closed when
      :func:`shutdown` is called. Subclasses should ensure that this gets called
      from overridden :meth:`close` methods.


   .. method:: Handler.handle(record)

      Conditionally emits the specified logging record, depending on filters which may
      have been added to the handler. Wraps the actual emission of the record with
      acquisition/release of the I/O thread lock.


   .. method:: Handler.handleError(record)

      This method should be called from handlers when an exception is encountered
      during an :meth:`emit` call. If the module-level attribute
      ``raiseExceptions`` is ``False``, exceptions get silently ignored. This is
      what is mostly wanted for a logging system - most users will not care about
      errors in the logging system, they are more interested in application
      errors. You could, however, replace this with a custom handler if you wish.
      The specified record is the one which was being processed when the exception
      occurred. (The default value of ``raiseExceptions`` is ``True``, as that is
      more useful during development).


   .. method:: Handler.format(record)

      Do formatting for a record - if a formatter is set, use it. Otherwise, use the
      default formatter for the module.


   .. method:: Handler.emit(record)

      Do whatever it takes to actually log the specified logging record. This version
      is intended to be implemented by subclasses and so raises a
      :exc:`NotImplementedError`.

For a list of handlers included as standard, see :mod:`logging.handlers`.

.. _formatter-objects:

포매터(Formatter) 객체
-------------------------------------

.. currentmodule:: logging

:class:`Formatter` objects have the following attributes and methods. They are
responsible for converting a :class:`LogRecord` to (usually) a string which can
be interpreted by either a human or an external system. The base
:class:`Formatter` allows a formatting string to be specified. If none is
supplied, the default value of ``'%(message)s'`` is used, which just includes
the message in the logging call. To have additional items of information in the
formatted output (such as a timestamp), keep reading.

A Formatter can be initialized with a format string which makes use of knowledge
of the :class:`LogRecord` attributes - such as the default value mentioned above
making use of the fact that the user's message and arguments are pre-formatted
into a :class:`LogRecord`'s *message* attribute.  This format string contains
standard Python %-style mapping keys. See section :ref:`old-string-formatting`
for more information on string formatting.

The useful mapping keys in a :class:`LogRecord` are given in the section on
:ref:`logrecord-attributes`.


.. class:: Formatter(fmt=None, datefmt=None, style='%')

   Returns a new instance of the :class:`Formatter` class.  The instance is
   initialized with a format string for the message as a whole, as well as a
   format string for the date/time portion of a message.  If no *fmt* is
   specified, ``'%(message)s'`` is used.  If no *datefmt* is specified, the
   ISO8601 date format is used.

   The *style* parameter can be one of '%', '{' or '$' and determines how
   the format string will be merged with its data: using one of %-formatting,
   :meth:`str.format` or :class:`string.Template`. See :ref:`formatting-styles`
   for more information on using {- and $-formatting for log messages.

   .. versionchanged:: 3.2
      The *style* parameter was added.


   .. method:: format(record)

      The record's attribute dictionary is used as the operand to a string
      formatting operation. Returns the resulting string. Before formatting the
      dictionary, a couple of preparatory steps are carried out. The *message*
      attribute of the record is computed using *msg* % *args*. If the
      formatting string contains ``'(asctime)'``, :meth:`formatTime` is called
      to format the event time. If there is exception information, it is
      formatted using :meth:`formatException` and appended to the message. Note
      that the formatted exception information is cached in attribute
      *exc_text*. This is useful because the exception information can be
      pickled and sent across the wire, but you should be careful if you have
      more than one :class:`Formatter` subclass which customizes the formatting
      of exception information. In this case, you will have to clear the cached
      value after a formatter has done its formatting, so that the next
      formatter to handle the event doesn't use the cached value but
      recalculates it afresh.

      If stack information is available, it's appended after the exception
      information, using :meth:`formatStack` to transform it if necessary.


   .. method:: formatTime(record, datefmt=None)

      This method should be called from :meth:`format` by a formatter which
      wants to make use of a formatted time. This method can be overridden in
      formatters to provide for any specific requirement, but the basic behavior
      is as follows: if *datefmt* (a string) is specified, it is used with
      :func:`time.strftime` to format the creation time of the
      record. Otherwise, the ISO8601 format is used.  The resulting string is
      returned.

      This function uses a user-configurable function to convert the creation
      time to a tuple. By default, :func:`time.localtime` is used; to change
      this for a particular formatter instance, set the ``converter`` attribute
      to a function with the same signature as :func:`time.localtime` or
      :func:`time.gmtime`. To change it for all formatters, for example if you
      want all logging times to be shown in GMT, set the ``converter``
      attribute in the ``Formatter`` class.

      .. versionchanged:: 3.3
         Previously, the default ISO 8601 format was hard-coded as in this
         example: ``2010-09-06 22:38:15,292`` where the part before the comma is
         handled by a strptime format string (``'%Y-%m-%d %H:%M:%S'``), and the
         part after the comma is a millisecond value. Because strptime does not
         have a format placeholder for milliseconds, the millisecond value is
         appended using another format string, ``'%s,%03d'`` --- and both of these
         format strings have been hardcoded into this method. With the change,
         these strings are defined as class-level attributes which can be
         overridden at the instance level when desired. The names of the
         attributes are ``default_time_format`` (for the strptime format string)
         and ``default_msec_format`` (for appending the millisecond value).

   .. method:: formatException(exc_info)

      Formats the specified exception information (a standard exception tuple as
      returned by :func:`sys.exc_info`) as a string. This default implementation
      just uses :func:`traceback.print_exception`. The resulting string is
      returned.

   .. method:: formatStack(stack_info)

      Formats the specified stack information (a string as returned by
      :func:`traceback.print_stack`, but with the last newline removed) as a
      string. This default implementation just returns the input value.

.. _filter:

필터(Filter) 객체
----------------------------

``Filters`` can be used by ``Handlers`` and ``Loggers`` for more sophisticated
filtering than is provided by levels. The base filter class only allows events
which are below a certain point in the logger hierarchy. For example, a filter
initialized with 'A.B' will allow events logged by loggers 'A.B', 'A.B.C',
'A.B.C.D', 'A.B.D' etc. but not 'A.BB', 'B.A.B' etc. If initialized with the
empty string, all events are passed.


.. class:: Filter(name='')

   Returns an instance of the :class:`Filter` class. If *name* is specified, it
   names a logger which, together with its children, will have its events allowed
   through the filter. If *name* is the empty string, allows every event.


   .. method:: filter(record)

      Is the specified record to be logged? Returns zero for no, nonzero for
      yes. If deemed appropriate, the record may be modified in-place by this
      method.

Note that filters attached to handlers are consulted before an event is
emitted by the handler, whereas filters attached to loggers are consulted
whenever an event is logged (using :meth:`debug`, :meth:`info`,
etc.), before sending an event to handlers. This means that events which have
been generated by descendant loggers will not be filtered by a logger's filter
setting, unless the filter has also been applied to those descendant loggers.

You don't actually need to subclass ``Filter``: you can pass any instance
which has a ``filter`` method with the same semantics.

.. versionchanged:: 3.2
   You don't need to create specialized ``Filter`` classes, or use other
   classes with a ``filter`` method: you can use a function (or other
   callable) as a filter. The filtering logic will check to see if the filter
   object has a ``filter`` attribute: if it does, it's assumed to be a
   ``Filter`` and its :meth:`~Filter.filter` method is called. Otherwise, it's
   assumed to be a callable and called with the record as the single
   parameter. The returned value should conform to that returned by
   :meth:`~Filter.filter`.

Although filters are used primarily to filter records based on more
sophisticated criteria than levels, they get to see every record which is
processed by the handler or logger they're attached to: this can be useful if
you want to do things like counting how many records were processed by a
particular logger or handler, or adding, changing or removing attributes in
the LogRecord being processed. Obviously changing the LogRecord needs to be
done with some care, but it does allow the injection of contextual information
into logs (see :ref:`filters-contextual`).

.. _log-record:

로그레코드(LogRecord) 객체
----------------------------------

:class:`LogRecord` instances are created automatically by the :class:`Logger`
every time something is logged, and can be created manually via
:func:`makeLogRecord` (for example, from a pickled event received over the
wire).


.. class:: LogRecord(name, level, pathname, lineno, msg, args, exc_info, func=None, sinfo=None)

   Contains all the information pertinent to the event being logged.

   The primary information is passed in :attr:`msg` and :attr:`args`, which
   are combined using ``msg % args`` to create the :attr:`message` field of the
   record.

   :param name:  The name of the logger used to log the event represented by
                 this LogRecord. Note that this name will always have this
                 value, even though it may be emitted by a handler attached to
                 a different (ancestor) logger.
   :param level: The numeric level of the logging event (one of DEBUG, INFO etc.)
                 Note that this is converted to *two* attributes of the LogRecord:
                 ``levelno`` for the numeric value and ``levelname`` for the
                 corresponding level name.
   :param pathname: The full pathname of the source file where the logging call
                    was made.
   :param lineno: The line number in the source file where the logging call was
                  made.
   :param msg: The event description message, possibly a format string with
               placeholders for variable data.
   :param args: Variable data to merge into the *msg* argument to obtain the
                event description.
   :param exc_info: An exception tuple with the current exception information,
                    or ``None`` if no exception information is available.
   :param func: The name of the function or method from which the logging call
                was invoked.
   :param sinfo: A text string representing stack information from the base of
                 the stack in the current thread, up to the logging call.

   .. method:: getMessage()

      Returns the message for this :class:`LogRecord` instance after merging any
      user-supplied arguments with the message. If the user-supplied message
      argument to the logging call is not a string, :func:`str` is called on it to
      convert it to a string. This allows use of user-defined classes as
      messages, whose ``__str__`` method can return the actual format string to
      be used.

   .. versionchanged:: 3.2
      The creation of a ``LogRecord`` has been made more configurable by
      providing a factory which is used to create the record. The factory can be
      set using :func:`getLogRecordFactory` and :func:`setLogRecordFactory`
      (see this for the factory's signature).

   This functionality can be used to inject your own values into a
   LogRecord at creation time. You can use the following pattern::

      old_factory = logging.getLogRecordFactory()

      def record_factory(*args, **kwargs):
          record = old_factory(*args, **kwargs)
          record.custom_attribute = 0xdecafbad
          return record

      logging.setLogRecordFactory(record_factory)

   With this pattern, multiple factories could be chained, and as long
   as they don't overwrite each other's attributes or unintentionally
   overwrite the standard attributes listed above, there should be no
   surprises.


.. _logrecord-attributes:

로그레코드(LogRecord) 속성
----------------------------------------

The LogRecord has a number of attributes, most of which are derived from the
parameters to the constructor. (Note that the names do not always correspond
exactly between the LogRecord constructor parameters and the LogRecord
attributes.) These attributes can be used to merge data from the record into
the format string. The following table lists (in alphabetical order) the
attribute names, their meanings and the corresponding placeholder in a %-style
format string.

If you are using {}-formatting (:func:`str.format`), you can use
``{attrname}`` as the placeholder in the format string. If you are using
$-formatting (:class:`string.Template`), use the form ``${attrname}``. In
both cases, of course, replace ``attrname`` with the actual attribute name
you want to use.

In the case of {}-formatting, you can specify formatting flags by placing them
after the attribute name, separated from it with a colon. For example: a
placeholder of ``{msecs:03d}`` would format a millisecond value of ``4`` as
``004``. Refer to the :meth:`str.format` documentation for full details on
the options available to you.

+----------------+-------------------------+-----------------------------------------------+
| Attribute name | Format                  | Description                                   |
+================+=========================+===============================================+
| args           | You shouldn't need to   | The tuple of arguments merged into ``msg`` to |
|                | format this yourself.   | produce ``message``, or a dict whose values   |
|                |                         | are used for the merge (when there is only one|
|                |                         | argument, and it is a dictionary).            |
+----------------+-------------------------+-----------------------------------------------+
| asctime        | ``%(asctime)s``         | Human-readable time when the                  |
|                |                         | :class:`LogRecord` was created.  By default   |
|                |                         | this is of the form '2003-07-08 16:49:45,896' |
|                |                         | (the numbers after the comma are millisecond  |
|                |                         | portion of the time).                         |
+----------------+-------------------------+-----------------------------------------------+
| created        | ``%(created)f``         | Time when the :class:`LogRecord` was created  |
|                |                         | (as returned by :func:`time.time`).           |
+----------------+-------------------------+-----------------------------------------------+
| exc_info       | You shouldn't need to   | Exception tuple (à la ``sys.exc_info``) or,   |
|                | format this yourself.   | if no exception has occurred, ``None``.       |
+----------------+-------------------------+-----------------------------------------------+
| filename       | ``%(filename)s``        | Filename portion of ``pathname``.             |
+----------------+-------------------------+-----------------------------------------------+
| funcName       | ``%(funcName)s``        | Name of function containing the logging call. |
+----------------+-------------------------+-----------------------------------------------+
| levelname      | ``%(levelname)s``       | Text logging level for the message            |
|                |                         | (``'DEBUG'``, ``'INFO'``, ``'WARNING'``,      |
|                |                         | ``'ERROR'``, ``'CRITICAL'``).                 |
+----------------+-------------------------+-----------------------------------------------+
| levelno        | ``%(levelno)s``         | Numeric logging level for the message         |
|                |                         | (:const:`DEBUG`, :const:`INFO`,               |
|                |                         | :const:`WARNING`, :const:`ERROR`,             |
|                |                         | :const:`CRITICAL`).                           |
+----------------+-------------------------+-----------------------------------------------+
| lineno         | ``%(lineno)d``          | Source line number where the logging call was |
|                |                         | issued (if available).                        |
+----------------+-------------------------+-----------------------------------------------+
| message        | ``%(message)s``         | The logged message, computed as ``msg %       |
|                |                         | args``. This is set when                      |
|                |                         | :meth:`Formatter.format` is invoked.          |
+----------------+-------------------------+-----------------------------------------------+
| module         | ``%(module)s``          | Module (name portion of ``filename``).        |
+----------------+-------------------------+-----------------------------------------------+
| msecs          | ``%(msecs)d``           | Millisecond portion of the time when the      |
|                |                         | :class:`LogRecord` was created.               |
+----------------+-------------------------+-----------------------------------------------+
| msg            | You shouldn't need to   | The format string passed in the original      |
|                | format this yourself.   | logging call. Merged with ``args`` to         |
|                |                         | produce ``message``, or an arbitrary object   |
|                |                         | (see :ref:`arbitrary-object-messages`).       |
+----------------+-------------------------+-----------------------------------------------+
| name           | ``%(name)s``            | Name of the logger used to log the call.      |
+----------------+-------------------------+-----------------------------------------------+
| pathname       | ``%(pathname)s``        | Full pathname of the source file where the    |
|                |                         | logging call was issued (if available).       |
+----------------+-------------------------+-----------------------------------------------+
| process        | ``%(process)d``         | Process ID (if available).                    |
+----------------+-------------------------+-----------------------------------------------+
| processName    | ``%(processName)s``     | Process name (if available).                  |
+----------------+-------------------------+-----------------------------------------------+
| relativeCreated| ``%(relativeCreated)d`` | Time in milliseconds when the LogRecord was   |
|                |                         | created, relative to the time the logging     |
|                |                         | module was loaded.                            |
+----------------+-------------------------+-----------------------------------------------+
| stack_info     | You shouldn't need to   | Stack frame information (where available)     |
|                | format this yourself.   | from the bottom of the stack in the current   |
|                |                         | thread, up to and including the stack frame   |
|                |                         | of the logging call which resulted in the     |
|                |                         | creation of this record.                      |
+----------------+-------------------------+-----------------------------------------------+
| thread         | ``%(thread)d``          | Thread ID (if available).                     |
+----------------+-------------------------+-----------------------------------------------+
| threadName     | ``%(threadName)s``      | Thread name (if available).                   |
+----------------+-------------------------+-----------------------------------------------+

.. versionchanged:: 3.1
   *processName* was added.


.. _logger-adapter:

로거어댑터(LoggerAdapter) 객체
------------------------------------------

:class:`LoggerAdapter` instances are used to conveniently pass contextual
information into logging calls. For a usage example, see the section on
:ref:`adding contextual information to your logging output <context-info>`.

.. class:: LoggerAdapter(logger, extra)

   Returns an instance of :class:`LoggerAdapter` initialized with an
   underlying :class:`Logger` instance and a dict-like object.

   .. method:: process(msg, kwargs)

      Modifies the message and/or keyword arguments passed to a logging call in
      order to insert contextual information. This implementation takes the object
      passed as *extra* to the constructor and adds it to *kwargs* using key
      'extra'. The return value is a (*msg*, *kwargs*) tuple which has the
      (possibly modified) versions of the arguments passed in.

In addition to the above, :class:`LoggerAdapter` supports the following
methods of :class:`Logger`: :meth:`~Logger.debug`, :meth:`~Logger.info`,
:meth:`~Logger.warning`, :meth:`~Logger.error`, :meth:`~Logger.exception`,
:meth:`~Logger.critical`, :meth:`~Logger.log`, :meth:`~Logger.isEnabledFor`,
:meth:`~Logger.getEffectiveLevel`, :meth:`~Logger.setLevel` and
:meth:`~Logger.hasHandlers`. These methods have the same signatures as their
counterparts in :class:`Logger`, so you can use the two types of instances
interchangeably.

.. versionchanged:: 3.2
   The :meth:`~Logger.isEnabledFor`, :meth:`~Logger.getEffectiveLevel`,
   :meth:`~Logger.setLevel` and :meth:`~Logger.hasHandlers` methods were added
   to :class:`LoggerAdapter`.  These methods delegate to the underlying logger.


쓰레드 안전성
--------------------------

The logging module is intended to be thread-safe without any special work
needing to be done by its clients. It achieves this though using threading
locks; there is one lock to serialize access to the module's shared data, and
each handler also creates a lock to serialize access to its underlying I/O.

If you are implementing asynchronous signal handlers using the :mod:`signal`
module, you may not be able to use logging from within such handlers. This is
because lock implementations in the :mod:`threading` module are not always
re-entrant, and so cannot be invoked from such signal handlers.


모듈레벨 함수
----------------------

In addition to the classes described above, there are a number of module- level
functions.


.. function:: getLogger(name=None)

   Return a logger with the specified name or, if name is ``None``, return a
   logger which is the root logger of the hierarchy. If specified, the name is
   typically a dot-separated hierarchical name like *'a'*, *'a.b'* or *'a.b.c.d'*.
   Choice of these names is entirely up to the developer who is using logging.

   All calls to this function with a given name return the same logger instance.
   This means that logger instances never need to be passed between different parts
   of an application.


.. function:: getLoggerClass()

   Return either the standard :class:`Logger` class, or the last class passed to
   :func:`setLoggerClass`. This function may be called from within a new class
   definition, to ensure that installing a customized :class:`Logger` class will
   not undo customizations already applied by other code. For example::

      class MyLogger(logging.getLoggerClass()):
          # ... override behaviour here


.. function:: getLogRecordFactory()

   Return a callable which is used to create a :class:`LogRecord`.

   .. versionadded:: 3.2
      This function has been provided, along with :func:`setLogRecordFactory`,
      to allow developers more control over how the :class:`LogRecord`
      representing a logging event is constructed.

   See :func:`setLogRecordFactory` for more information about the how the
   factory is called.

.. function:: debug(msg, *args, **kwargs)

   Logs a message with level :const:`DEBUG` on the root logger. The *msg* is the
   message format string, and the *args* are the arguments which are merged into
   *msg* using the string formatting operator. (Note that this means that you can
   use keywords in the format string, together with a single dictionary argument.)

   There are three keyword arguments in *kwargs* which are inspected: *exc_info*
   which, if it does not evaluate as false, causes exception information to be
   added to the logging message. If an exception tuple (in the format returned by
   :func:`sys.exc_info`) is provided, it is used; otherwise, :func:`sys.exc_info`
   is called to get the exception information.

   The second optional keyword argument is *stack_info*, which defaults to
   ``False``. If true, stack information is added to the logging
   message, including the actual logging call. Note that this is not the same
   stack information as that displayed through specifying *exc_info*: The
   former is stack frames from the bottom of the stack up to the logging call
   in the current thread, whereas the latter is information about stack frames
   which have been unwound, following an exception, while searching for
   exception handlers.

   You can specify *stack_info* independently of *exc_info*, e.g. to just show
   how you got to a certain point in your code, even when no exceptions were
   raised. The stack frames are printed following a header line which says::

       Stack (most recent call last):

   This mimics the ``Traceback (most recent call last):`` which is used when
   displaying exception frames.

   The third optional keyword argument is *extra* which can be used to pass a
   dictionary which is used to populate the __dict__ of the LogRecord created for
   the logging event with user-defined attributes. These custom attributes can then
   be used as you like. For example, they could be incorporated into logged
   messages. For example::

      FORMAT = '%(asctime)-15s %(clientip)s %(user)-8s %(message)s'
      logging.basicConfig(format=FORMAT)
      d = {'clientip': '192.168.0.1', 'user': 'fbloggs'}
      logging.warning('Protocol problem: %s', 'connection reset', extra=d)

   would print something like::

      2006-02-08 22:20:02,165 192.168.0.1 fbloggs  Protocol problem: connection reset

   The keys in the dictionary passed in *extra* should not clash with the keys used
   by the logging system. (See the :class:`Formatter` documentation for more
   information on which keys are used by the logging system.)

   If you choose to use these attributes in logged messages, you need to exercise
   some care. In the above example, for instance, the :class:`Formatter` has been
   set up with a format string which expects 'clientip' and 'user' in the attribute
   dictionary of the LogRecord. If these are missing, the message will not be
   logged because a string formatting exception will occur. So in this case, you
   always need to pass the *extra* dictionary with these keys.

   While this might be annoying, this feature is intended for use in specialized
   circumstances, such as multi-threaded servers where the same code executes in
   many contexts, and interesting conditions which arise are dependent on this
   context (such as remote client IP address and authenticated user name, in the
   above example). In such circumstances, it is likely that specialized
   :class:`Formatter`\ s would be used with particular :class:`Handler`\ s.

   .. versionadded:: 3.2
      The *stack_info* parameter was added.

.. function:: info(msg, *args, **kwargs)

   Logs a message with level :const:`INFO` on the root logger. The arguments are
   interpreted as for :func:`debug`.


.. function:: warning(msg, *args, **kwargs)

   Logs a message with level :const:`WARNING` on the root logger. The arguments
   are interpreted as for :func:`debug`.

   .. note:: There is an obsolete function ``warn`` which is functionally
      identical to ``warning``. As ``warn`` is deprecated, please do not use
      it - use ``warning`` instead.


.. function:: error(msg, *args, **kwargs)

   Logs a message with level :const:`ERROR` on the root logger. The arguments are
   interpreted as for :func:`debug`.


.. function:: critical(msg, *args, **kwargs)

   Logs a message with level :const:`CRITICAL` on the root logger. The arguments
   are interpreted as for :func:`debug`.


.. function:: exception(msg, *args, **kwargs)

   Logs a message with level :const:`ERROR` on the root logger. The arguments are
   interpreted as for :func:`debug`. Exception info is added to the logging
   message. This function should only be called from an exception handler.

.. function:: log(level, msg, *args, **kwargs)

   Logs a message with level *level* on the root logger. The other arguments are
   interpreted as for :func:`debug`.

   .. note:: The above module-level convenience functions, which delegate to the
      root logger, call :func:`basicConfig` to ensure that at least one handler
      is available. Because of this, they should *not* be used in threads,
      in versions of Python earlier than 2.7.1 and 3.2, unless at least one
      handler has been added to the root logger *before* the threads are
      started. In earlier versions of Python, due to a thread safety shortcoming
      in :func:`basicConfig`, this can (under rare circumstances) lead to
      handlers being added multiple times to the root logger, which can in turn
      lead to multiple messages for the same event.

.. function:: disable(lvl=CRITICAL)

   Provides an overriding level *lvl* for all loggers which takes precedence over
   the logger's own level. When the need arises to temporarily throttle logging
   output down across the whole application, this function can be useful. Its
   effect is to disable all logging calls of severity *lvl* and below, so that
   if you call it with a value of INFO, then all INFO and DEBUG events would be
   discarded, whereas those of severity WARNING and above would be processed
   according to the logger's effective level. If
   ``logging.disable(logging.NOTSET)`` is called, it effectively removes this
   overriding level, so that logging output again depends on the effective
   levels of individual loggers.

   Note that if you have defined any custom logging level higher than
   ``CRITICAL`` (this is not recommended), you won't be able to rely on the
   default value for the *lvl* parameter, but will have to explicitly supply a
   suitable value.

   .. versionchanged:: 3.7
      The *lvl* parameter was defaulted to level ``CRITICAL``. See Issue
      #28524 for more information about this change.

.. function:: addLevelName(lvl, levelName)

   Associates level *lvl* with text *levelName* in an internal dictionary, which is
   used to map numeric levels to a textual representation, for example when a
   :class:`Formatter` formats a message. This function can also be used to define
   your own levels. The only constraints are that all levels used must be
   registered using this function, levels should be positive integers and they
   should increase in increasing order of severity.

   .. note:: If you are thinking of defining your own levels, please see the
      section on :ref:`custom-levels`.

.. function:: getLevelName(lvl)

   Returns the textual representation of logging level *lvl*. If the level is one
   of the predefined levels :const:`CRITICAL`, :const:`ERROR`, :const:`WARNING`,
   :const:`INFO` or :const:`DEBUG` then you get the corresponding string. If you
   have associated levels with names using :func:`addLevelName` then the name you
   have associated with *lvl* is returned. If a numeric value corresponding to one
   of the defined levels is passed in, the corresponding string representation is
   returned. Otherwise, the string 'Level %s' % lvl is returned.

   .. note:: Levels are internally integers (as they need to be compared in the
      logging logic). This function is used to convert between an integer level
      and the level name displayed in the formatted log output by means of the
      ``%(levelname)s`` format specifier (see :ref:`logrecord-attributes`).

   .. versionchanged:: 3.4
      In Python versions earlier than 3.4, this function could also be passed a
      text level, and would return the corresponding numeric value of the level.
      This undocumented behaviour was considered a mistake, and was removed in
      Python 3.4, but reinstated in 3.4.2 due to retain backward compatibility.

.. function:: makeLogRecord(attrdict)

   Creates and returns a new :class:`LogRecord` instance whose attributes are
   defined by *attrdict*. This function is useful for taking a pickled
   :class:`LogRecord` attribute dictionary, sent over a socket, and reconstituting
   it as a :class:`LogRecord` instance at the receiving end.


.. function:: basicConfig(**kwargs)

   Does basic configuration for the logging system by creating a
   :class:`StreamHandler` with a default :class:`Formatter` and adding it to the
   root logger. The functions :func:`debug`, :func:`info`, :func:`warning`,
   :func:`error` and :func:`critical` will call :func:`basicConfig` automatically
   if no handlers are defined for the root logger.

   This function does nothing if the root logger already has handlers
   configured for it.

   .. note:: This function should be called from the main thread
      before other threads are started. In versions of Python prior to
      2.7.1 and 3.2, if this function is called from multiple threads,
      it is possible (in rare circumstances) that a handler will be added
      to the root logger more than once, leading to unexpected results
      such as messages being duplicated in the log.

   The following keyword arguments are supported.

   .. tabularcolumns:: |l|L|

   +--------------+---------------------------------------------+
   | Format       | Description                                 |
   +==============+=============================================+
   | ``filename`` | Specifies that a FileHandler be created,    |
   |              | using the specified filename, rather than a |
   |              | StreamHandler.                              |
   +--------------+---------------------------------------------+
   | ``filemode`` | Specifies the mode to open the file, if     |
   |              | filename is specified (if filemode is       |
   |              | unspecified, it defaults to 'a').           |
   +--------------+---------------------------------------------+
   | ``format``   | Use the specified format string for the     |
   |              | handler.                                    |
   +--------------+---------------------------------------------+
   | ``datefmt``  | Use the specified date/time format.         |
   +--------------+---------------------------------------------+
   | ``style``    | If ``format`` is specified, use this style  |
   |              | for the format string. One of '%', '{' or   |
   |              | '$' for %-formatting, :meth:`str.format` or |
   |              | :class:`string.Template` respectively, and  |
   |              | defaulting to '%' if not specified.         |
   +--------------+---------------------------------------------+
   | ``level``    | Set the root logger level to the specified  |
   |              | level.                                      |
   +--------------+---------------------------------------------+
   | ``stream``   | Use the specified stream to initialize the  |
   |              | StreamHandler. Note that this argument is   |
   |              | incompatible with 'filename' - if both are  |
   |              | present, a ``ValueError`` is raised.        |
   +--------------+---------------------------------------------+
   | ``handlers`` | If specified, this should be an iterable of |
   |              | already created handlers to add to the root |
   |              | logger. Any handlers which don't already    |
   |              | have a formatter set will be assigned the   |
   |              | default formatter created in this function. |
   |              | Note that this argument is incompatible     |
   |              | with 'filename' or 'stream' - if both are   |
   |              | present, a ``ValueError`` is raised.        |
   +--------------+---------------------------------------------+

   .. versionchanged:: 3.2
      The ``style`` argument was added.

   .. versionchanged:: 3.3
      The ``handlers`` argument was added. Additional checks were added to
      catch situations where incompatible arguments are specified (e.g.
      ``handlers`` together with ``stream`` or ``filename``, or ``stream``
      together with ``filename``).


.. function:: shutdown()

   Informs the logging system to perform an orderly shutdown by flushing and
   closing all handlers. This should be called at application exit and no
   further use of the logging system should be made after this call.


.. function:: setLoggerClass(klass)

   Tells the logging system to use the class *klass* when instantiating a logger.
   The class should define :meth:`__init__` such that only a name argument is
   required, and the :meth:`__init__` should call :meth:`Logger.__init__`. This
   function is typically called before any loggers are instantiated by applications
   which need to use custom logger behavior.


.. function:: setLogRecordFactory(factory)

   Set a callable which is used to create a :class:`LogRecord`.

   :param factory: The factory callable to be used to instantiate a log record.

   .. versionadded:: 3.2
      This function has been provided, along with :func:`getLogRecordFactory`, to
      allow developers more control over how the :class:`LogRecord` representing
      a logging event is constructed.

   The factory has the following signature:

   ``factory(name, level, fn, lno, msg, args, exc_info, func=None, sinfo=None, **kwargs)``

      :name: The logger name.
      :level: The logging level (numeric).
      :fn: The full pathname of the file where the logging call was made.
      :lno: The line number in the file where the logging call was made.
      :msg: The logging message.
      :args: The arguments for the logging message.
      :exc_info: An exception tuple, or ``None``.
      :func: The name of the function or method which invoked the logging
             call.
      :sinfo: A stack traceback such as is provided by
              :func:`traceback.print_stack`, showing the call hierarchy.
      :kwargs: Additional keyword arguments.


모듈레벨 속성
-----------------------

.. attribute:: lastResort

   A "handler of last resort" is available through this attribute. This
   is a :class:`StreamHandler` writing to ``sys.stderr`` with a level of
   ``WARNING``, and is used to handle logging events in the absence of any
   logging configuration. The end result is to just print the message to
   ``sys.stderr``. This replaces the earlier error message saying that
   "no handlers could be found for logger XYZ". If you need the earlier
   behaviour for some reason, ``lastResort`` can be set to ``None``.

   .. versionadded:: 3.2

warnings 모듈과의 통합
------------------------------------

The :func:`captureWarnings` function can be used to integrate :mod:`logging`
with the :mod:`warnings` module.

.. function:: captureWarnings(capture)

   This function is used to turn the capture of warnings by logging on and
   off.

   If *capture* is ``True``, warnings issued by the :mod:`warnings` module will
   be redirected to the logging system. Specifically, a warning will be
   formatted using :func:`warnings.formatwarning` and the resulting string
   logged to a logger named ``'py.warnings'`` with a severity of :const:`WARNING`.

   If *capture* is ``False``, the redirection of warnings to the logging system
   will stop, and warnings will be redirected to their original destinations
   (i.e. those in effect before ``captureWarnings(True)`` was called).


.. seealso::

   Module :mod:`logging.config`
      Configuration API for the logging module.

   Module :mod:`logging.handlers`
      Useful handlers included with the logging module.

   :pep:`282` - A Logging System
      The proposal which described this feature for inclusion in the Python standard
      library.

   `Original Python logging package <https://www.red-dove.com/python_logging.html>`_
      This is the original source for the :mod:`logging` package.  The version of the
      package available from this site is suitable for use with Python 1.5.2, 2.1.x
      and 2.2.x, which do not include the :mod:`logging` package in the standard
      library.
