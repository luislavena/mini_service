#ifndef __MINI_SERVICE_BI__
#define __MINI_SERVICE_BI__

#include once "windows.bi"
#inclib "advapi32"

type MiniService
  '# possible service states
  enum StateEnum
    Running = SERVICE_RUNNING
    Paused  = SERVICE_PAUSED
    Stopped = SERVICE_STOPPED
  end enum

  declare constructor(as string)
  declare destructor()

  '# methods
  declare sub run()
  declare sub ping(as integer)

  '# properties (read-only)
  declare property name           as string
  declare property command_line   as string
  declare property state          as StateEnum

  '# event callbacks
  '# required:
  onStart   as sub(as MiniService)

  '# optional:
  onInit    as sub(as MiniService)
  onStop    as sub(as MiniService)

  '# use this to store any extra reference (pseudo inheritance)
  extra     as any ptr

private:

end type

#endif
