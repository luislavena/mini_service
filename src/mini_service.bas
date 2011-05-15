#include once "mini_service.bi"

constructor MiniService(byref new_name as string)
  debug("setting up new name")
  _name = new_name

  '# initial service values
  debug("initial service status values")
  with status
    .dwServiceType = SERVICE_WIN32_OWN_PROCESS
    .dwCurrentState = SERVICE_STOPPED
    .dwControlsAccepted = (SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN)
    .dwWin32ExitCode = NO_ERROR
    .dwServiceSpecificExitCode = NO_ERROR
    .dwCheckPoint = 0
    .dwWaitHint = 0
  end with

  '# Initial state
  debug("assigning an initial state as Stopped")
  _state = Stopped

  '# create condition and mutex for synchronization
  debug("creating stop event")
  stop_event = CreateEvent(0, FALSE, FALSE, 0)
end constructor

destructor MiniService()
  debug("clean up after our party!")
  CloseHandle(stop_event)
end destructor

property MiniService.state() as States
  return _state
end property

function MiniService.singleton(byval new_value as MiniService ptr = 0) as MiniService ptr
  static _singleton as MiniService ptr

  if not (new_value = 0) then
    debug("setting new singleton reference: " + hex(new_value))
    _singleton = new_value
  end if

  return _singleton
end function

sub MiniService.run()
  dim service_table(1) as SERVICE_TABLE_ENTRY

  debug("about to run!")

  '# track this instance as singleton
  MiniService.singleton(@this)

  '# build the service table and references
  debug("setting up first entry in service_table for " + _name + " @ " + hex(@MiniService.control_dispatcher))

  service_table(0) = type<SERVICE_TABLE_ENTRY>( _
    strptr(_name), _
    @MiniService.control_dispatcher _
  )

  '# terminate service table with null information
  service_table(1) = type<SERVICE_TABLE_ENTRY>(0, 0)

  '# start the control dispatcher with the list
  debug("start service dispatcher")
  StartServiceCtrlDispatcher(@service_table(0))

  debug("run() done")
end sub

sub MiniService.control_dispatcher(byval argc as DWORD, byval argv as LPSTR ptr)
  var service = MiniService.singleton()

  '# build the command line for the service
  service->build_command_line()

  '# register service control handler
  service->register_handler()

  '# invoke all the hooks defined
  service->perform()
end sub

sub MiniService.register_handler()

  debug("register control handler")
  status_handle = RegisterServiceCtrlHandlerEx( _
    strptr(_name), _
    @control_handler_ex, _
    @this _
  )
end sub

sub MiniService.perform()
  dim worker as any ptr

  '# got handle? good, let's proceed
  if not (status_handle = 0) then
    debug("switch state to start pending")
    update_state(SERVICE_START_PENDING)

    '# perform onInit (if present)
    if not (onInit = 0) then
      debug("invoking onInit")
      onInit(@this)
    end if

    '# we should switch to running state
    update_state(SERVICE_RUNNING)

    if not (onStart = 0) then
      debug("invoking onStart, on a worker thread")
      worker = threadcreate(@MiniService.invoke_onStart, @this)
    end if

    '# now, we wait for our stop signal
    debug("waiting for stop_event signaling")
    do
      '# do nothing ...
      '# but not too often!
    loop while (WaitForSingleObject(stop_event, 100) = WAIT_TIMEOUT)

    '# now let's way for our thread to complete
    debug("now wait for onStart to complete")
    threadwait(worker)

    '# update status, we're done
    debug("done, mark the service as stopped")
    update_state(SERVICE_STOPPED)
  end if
end sub

sub MiniService.invoke_onStart(byval any_service as any ptr)
  var service = cast(MiniService ptr, any_service)
  debug("calling onStart")
  service->onStart(service)
end sub

function MiniService.control_handler_ex(byval dwControl as DWORD, byval dwEventType as DWORD, byval lpEventData as LPVOID, byval lpContext as LPVOID) as DWORD
  dim result as DWORD
  var service = cast(MiniService ptr, lpContext)

  debug("about to process control signal")
  select case dwControl
    case SERVICE_CONTROL_INTERROGATE:
      debug("interrogate signal received")
      result = NO_ERROR

    case SERVICE_CONTROL_SHUTDOWN, SERVICE_CONTROL_STOP:
      debug("stop or shutdown received, invoking perform_stop()")
      service->perform_stop()

    case else:
      result = NO_ERROR
  end select

  return result
end function

sub MiniService.perform_stop()
  '# update status to reflect we are stopping
  update_state(SERVICE_STOP_PENDING)

  '# invoke onStop if defined
  if not (onStop = 0) then
    debug("invoking onStop")
    onStop(@this)
  end if

  '# now trigger stop_event
  debug("triggering stop event")
  SetEvent(stop_event)
end sub

sub MiniService.update_state(byval new_state as DWORD, byval checkpoint as integer = 0, byval waithint as integer = 0)

  debug("adjusting service state")
  select case new_state
    '# disable the option to accept other commands during pending operations
    case SERVICE_START_PENDING, SERVICE_STOP_PENDING:
      debug("disabling commands during pending operations")
      status.dwControlsAccepted = 0

    '# when running a service can accept stop or shutdown events
    case SERVICE_RUNNING:
      debug("accept stop and shutdown when running")
      status.dwControlsAccepted = (SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN)
  end select

  '# adjust status structure also with new state and our property
  status.dwCurrentState = new_state
  _state = new_state

  '# set checkpoint and waithint
  status.dwCheckPoint = checkpoint
  status.dwWaitHint = waithint

  '# use our handle to notify the status update
  if not (status_handle = 0) then
    debug("notify windows using SetServiceStatus API")
    SetServiceStatus(status_handle, @status)
  end if
end sub

sub MiniService.build_command_line()
  dim as string result, token
  dim idx as integer

  debug("commands passed to ImagePath (excluding executable):")
  idx = 1
  token = command(idx)
  do while (len(token) > 0)
    debug("token: " + token)

    if (instr(token, chr(32)) > 0) then
      '# quote around parameter with spaces
      result += """" + token + """"
    else
      result += token
    end if
    result += " "
    idx += 1

    token = command(idx)
  loop

  _command_line = result

  debug("command line: " + _command_line)
end sub

'# DEBUG
sub debug_file(byref msg as string)
  dim handler as integer

  handler = freefile
  open EXEPATH + "\service.log" for append as #handler
  print #handler, msg

  close #handler
end sub
