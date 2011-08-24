# encoding: utf-8
ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler'
Bundler.setup(:default)

require 'active_support'
require 'action_controller'
require 'active_model'
require 'rails/railtie'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/map_layers'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/map_layers/view_helpers'))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories in alphabetic order.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}

class ApplicationController < ActionController::Base
  include MapLayers
  include MapLayers::ViewHelpers

  self.view_paths = File.join(File.dirname(__FILE__), 'views')
  respond_to :html, :kml
end

class PlacesController < ApplicationController

    map_layer :place, :text => :placeName

end

class ActiveSupport::TestCase
  setup do
    @routes = Responders::Routes
  end
end

class Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :persisted, :updated_at
  alias :persisted? :persisted

  def persisted?
    @persisted
  end

  def to_xml(*args)
    "<xml />"
  end

  def initialize(updated_at=nil)
    @persisted = true
    self.updated_at = updated_at
  end
end

class TestMap < Model
  include MapLayers
  include MapLayers::ViewHelpers

  def projection(name)
    OpenLayers::Projection.new(name)
  end

  def id
    "map"
  end

  def controls
    []
  end
  
  def map
    @map ||= MapLayers::Map.new(id, :projection => projection("EPSG:900913"), :controls => controls)
  end

end

class Place < Model
  attr_accessor :placeName, :countryCode, :postalCode, :lat, :lng
end

# @place = ::Place.new
# @place.stub!(:class).and_return(::Place)
# @place.stub!(:placeName).and_return("place name")
# @place.stub!(:countryCode).and_return("92")
# @place.stub!(:postalCode).and_return("92000")
# @place.stub!(:lat).and_return("1")
# @place.stub!(:lng).and_return("1")
# @place.stub!(:id).and_return(37)
# @place.stub!(:new_record?).and_return(false)
# @place.stub!(:errors).and_return(mock('errors', :[] => nil))
# @place.stub!(:to_key).and_return(nil)
# @place.stub!(:persisted?).and_return(nil)
