# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "map_layers/version"

Gem::Specification.new do |s|       
  s.name        = "map_layers"
  s.version     = MapLayers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luc Donnet", "Alban Peignier", "Pirmin Kalberer"] 
  s.email       = ["luc.donnet@dryade.net", "alban.peignier@dryade.net", "pka@sourcepole.ch"]
  s.homepage    = "http://github.com/ldonnet/map_layers"
  s.summary     = %q{library dedicated to generate OSM javascript}
  s.description = %q{library dedicated to generate OSM javascript}

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]	

  if ENV['RAILS_3']        
    s.add_development_dependency(%q<rails>, ["~> 3.0.0"])
  else
    s.add_development_dependency(%q<rails>, [">= 2.3.8"])
  end
  s.add_development_dependency(%q<rspec>, ["~> 2.0.0"])
  s.add_development_dependency(%q<rspec-rails>, ["~> 2.0.0"])

  s.add_development_dependency('rake')
  s.add_development_dependency('autotest-rails')
  s.add_development_dependency('autotest-notification') 		
end
