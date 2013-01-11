require 'minitest/autorun'
require 'minitest/pride'
#require 'pp'

# minitest and turn
#require 'minitest_helper'

ENV["RAILS_ENV"] = "test"

require "active_support"
require "action_controller"
require "rails/railtie"
require "rails/engine"
require "i18n"

$:.unshift File.expand_path('../../lib', __FILE__)
require 'map_layers'

MapLayers::Routes = ActionDispatch::Routing::RouteSet.new
MapLayers::Routes.draw do
  match ':controller(/:action(/:id))'
end

ActionController::Base.send :include, MapLayers::Routes.url_helpers

