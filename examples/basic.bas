#include once "mini_service.bi"

type BasicService
  declare constructor()
  declare destructor()

  declare sub run()

private:
  _service as MiniService ptr

  declare static sub onStart(as MiniService)
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

sub BasicService.onStart(service as MiniService)
  var this = cast(BasicService ptr, service.extra)
end sub

dim service as BasicService
service.run()
