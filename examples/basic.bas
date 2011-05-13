#include once "mini_service.bi"

type BasicService
  declare constructor()
  declare destructor()

  declare sub run()

private:
  _service as MiniService ptr

  declare static sub onStart(byval as MiniService ptr)
end type

constructor BasicService()
  _service = new MiniService("BasicService")
  _service->onStart = @BasicService.onStart
  _service->extra = @this
end constructor

destructor BasicService()
  _service->onStart = 0
  _service->extra = 0
  delete _service
end destructor

sub BasicService.run()
  _service->run()
end sub

sub BasicService.onStart(byval service as MiniService ptr)
  var this = cast(BasicService ptr, service->extra)

  do while (service->state = MiniService.States.Running)
    sleep 100
  loop

end sub

sub main()
  dim myservice as BasicService
  myservice.run()
end sub

main()
