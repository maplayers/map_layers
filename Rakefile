#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/notes/rake_task' # notes (TODO, FIXME, OPTIMIZE)

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'lib/map_layers'
  t.libs << 'test' # to find test_helper
  t.test_files = FileList["test/**/*_test.rb"]
  #t.verbose = !!ENV["VERBOSE"]
  t.verbose = true
end
task :default => :test
