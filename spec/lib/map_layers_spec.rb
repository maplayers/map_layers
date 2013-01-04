require 'spec_helper'

describe MapLayers do

  describe ".const_missing" do

    it "should return a class with a child of MapLayers" do
      OpenLayers::Test.name.should == "OpenLayers::Test"
    end

    it "should return a class with a little child of MapLayers" do
      OpenLayers::Test::Toto.name.should == "OpenLayers::Test::Toto"
    end

  end

  describe "ApplicationController" do
    subject {ApplicationController}

    it "should have a map_layer method" do
      subject.methods.include?("map_layer").should be_true
    end

    it "should have a map_layer_config method" do
      subject.methods.include?("map_layers_config").should be_true
    end

  end

  describe "PlacesController" do
    subject {PlacesController}

    it "should exist an application model" do
      #puts subject.inspect
    end

  end

  describe "TestMap" do
    subject {TestMap.new}

    describe "#projection" do

      it "should return an openlayers projection" do
        OpenLayers::Projection.should_receive(:new).with("4326")
        subject.projection("4326")
      end

    end

    describe "#map" do

      it "should return a map" do
        projection = OpenLayers::Projection.new("EPSG:900913")
        OpenLayers::Projection.stub!(:new) {projection}
        MapLayers::Map.should_receive(:new).with("map", :projection => projection, :controls => [])
        subject.map
      end

    end
  end

end
