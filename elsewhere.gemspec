# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "elsewhere/version"

Gem::Specification.new do |s|
  s.name        = "elsewhere"
  s.version     = Elsewhere::VERSION
  s.authors     = ["Bill Chapman"]
  s.email       = ["bchapman@academicmanagement.com"]
  s.homepage    = ""
  s.summary     = %q{ Simple wrapper for Net SSH to run a list of commands remotely }
  s.description = %q{ Yet another way to run stuff remotely }

  s.rubyforge_project = "elsewhere"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency 'minitest'
  s.add_runtime_dependency 'net-ssh'
  s.add_runtime_dependency 'net-ssh-gateway'
  
end
