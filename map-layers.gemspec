# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "map_layers/version"

Gem::Specification.new do |s|

  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('rspec')
  s.add_development_dependency('autotest')
  s.add_development_dependency('autotest-notification')

  s.name        = "map-layers"
  s.version     = MapLayers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luc Donnet", "Alban Peignier"]
  s.email       = ["luc.donnet@dryade.net", "alban.peignier@dryade.net"]
  s.homepage    = ""
  s.summary     = %q{library dedicated to generate OSM javascript}
  s.description = %q{library dedicated to generate OSM javascript}

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
