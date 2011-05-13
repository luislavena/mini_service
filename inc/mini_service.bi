#ifndef __MINI_SERVICE_BI__
#define __MINI_SERVICE_BI__

#include once "windows.bi"
#inclib "advapi32"

type MiniService
  '# possible service states
  enum States
    Running = SERVICE_RUNNING
    Paused  = SERVICE_PAUSED
    Stopped = SERVICE_STOPPED
  end enum

  declare constructor(byref as string)
  declare destructor()

  '# methods
  declare sub run()
  declare sub ping(byval as integer)

  '# properties (read-only)
  declare property name           as string
  declare property command_line   as string
  declare property state          as States

  '# event callbacks
  '# required:
  onStart   as sub(byval as MiniService ptr)

  '# optional:
  onInit    as sub(byval as MiniService ptr)
  onStop    as sub(byval as MiniService ptr)

  '# use this to store any extra reference (pseudo inheritance)
  extra     as any ptr

private:

end type

#endif
