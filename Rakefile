require File.expand_path("rakehelp/freebasic", File.dirname(__FILE__))

defaults = {
  :mt       => true,  # we require multithread
  :pedantic => true,  # we like noisy warnings
  :debug    => ENV["DEBUG"] ? true : false # optional debugging
}

namespace "lib" do
  project_task "mini_service" do
    lib "mini_service"
    build_to "lib/win32"

    search_path "inc"
    source "src/mini_service.bas"

    library "user32", "advapi32"

    option defaults
  end
end

namespace "examples" do
  task "build" => ["lib:build"]
  project_task "basic" do
    executable  "basic"
    build_to    "examples"

    search_path "inc"
    lib_path    "lib/win32"

    main        "examples/basic.bas"

    library     "mini_service"

    option defaults
  end
end

task :build => ["lib:build", "examples:build"]
task :clobber => ["lib:clobber", "examples:clobber"]

task :default => [:build]
task :run => [:build] do
  sh "examples/basic"
end
