require File.expand_path("rakehelp/freebasic", File.dirname(__FILE__))

namespace "lib" do
  project_task "mini_service" do
    lib "mini_service"
    build_to "lib/win32"

    search_path "inc"
    source "src/mini_service.bas"

    library "user32", "advapi32"
  end
end
