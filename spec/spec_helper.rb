require 'rspec'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/map_layers'))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories in alphabetic order.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}
