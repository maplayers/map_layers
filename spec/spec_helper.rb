# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup

require 'active_support'
require 'action_view'
require 'action_controller'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/map_layers'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/map_layers/view_helpers'))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories in alphabetic order.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}
