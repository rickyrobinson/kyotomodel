# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kyotomodel/version"

Gem::Specification.new do |s|
  s.name        = "kyotomodel"
  s.version     = KyotoModel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ricky Robinson"]
  s.email       = ["ricky@rickyrobinson.id.au"]
  s.homepage    = ""
  s.summary     = %q{Stores models in Kyoto Tycoon.}
  s.description = %q{Persists models to Kyoto Tycoon. Based on the Supermodel gem.}

  s.rubyforge_project = "kyotomodel"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "msgpack"
  s.add_dependency "kyototycoon"
  s.add_dependency "supermodel"
end
