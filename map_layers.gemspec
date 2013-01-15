# -*- encoding: utf-8 -*-
require File.expand_path('../lib/map_layers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Kienlen", "Luc Donnet", "Alban Peignier", "Pirmin Kalberer"] 
  gem.email         = ["thomas.kienlen@lafourmi-immo.com", "luc.donnet@free.fr", "alban.peignier@free.fr", "pka@sourcepole.ch"]
  gem.description   = %q{library dedicated to generate OSM javascript}
  gem.summary       = %q{library dedicated to generate OSM javascript}
  gem.homepage      = "http://github.com/kmmndr/map_layers"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.name          = "map_layers"
  gem.require_paths = ["lib"]	
  gem.version       = MapLayers::VERSION

  gem.add_development_dependency 'rails', '~> 3.2.0'
  gem.add_development_dependency 'rake-notes' # tmp
  #gem.add_development_dependency(%q<rspec>, ["~> 2.0.0"])
  #gem.add_development_dependency(%q<rspec-rails>, ["~> 2.0.0"])

  #gem.add_development_dependency('rake')
  #gem.add_development_dependency('autotest-rails')
  #gem.add_development_dependency('autotest-notification')
  unless ENV["CI"]
    gem.add_development_dependency "turn", "~> 0.9" if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
  end
end
