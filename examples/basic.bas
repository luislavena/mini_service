#include once "mini_service.bi"

type BasicService
  declare constructor()
  declare destructor()

  declare sub run()

private:
  base as MiniService ptr

  declare static sub onStart(byval as MiniService ptr)
end type

constructor BasicService()
  base = new MiniService("BasicService")
  base->onStart = @BasicService.onStart
  base->extra = @this
end constructor

destructor BasicService()
  base->onStart = 0
  base->extra = 0
  delete base
end destructor

sub BasicService.run()
  base->run()
end sub

sub BasicService.onStart(byval base as MiniService ptr)
  var this = cast(BasicService ptr, base->extra)

  do while (base->state = MiniService.States.Running)
    sleep 100
  loop

end sub

sub main()
  dim myservice as BasicService
  myservice.run()
end sub

main()
