require File.expand_path("rakehelp/freebasic", File.dirname(__FILE__))
require "rake/packagetask"

PRODUCT_NAME = "mini_service"
PRODUCT_VERSION = "0.1.0"

defaults = {
  :mt       => true,                       # we require multithread
  :pedantic => true,                       # noisy warnings
  :trace    => ENV.fetch("TRACE", false),  # generate a log file
  :debug    => ENV.fetch("DEBUG", false)   # optional debugging
}

namespace "lib" do
  project_task "mini_service" do
    lib "mini_service"
    build_to "lib/win32"

    if defaults[:trace]
      define "_TRACE_FILE"
    end

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
task :rebuild => ["lib:rebuild", "examples:rebuild"]
task :clobber => ["lib:clobber", "examples:clobber"]

task :default => [:build]

# Source code package
Rake::PackageTask.new(PRODUCT_NAME, PRODUCT_VERSION) do |pkg|
  pkg.need_zip = true
  pkg.package_files = FileList[
    "examples/*.bas", "inc/*.bi", "src/*.bas",
    "README.md", "LICENSE.txt", "History.txt",
    "rakehelp/freebasic.rb", "Rakefile"
  ]
end
