# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vms/version"

Gem::Specification.new do |s|
  s.name        = "vms"
  s.version     = Vms::VERSION
  s.authors     = ["TALHO"]
  s.email       = ["developers@talho.org"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}
  
  s.files         = `git ls-files -- {app,config,db,lib}`.split("\n")
  s.test_files    = `git ls-files -- {features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
