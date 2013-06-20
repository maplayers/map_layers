require 'test_helper'

describe MapLayers::OpenLayers do

  describe ".const_missing" do
    it "should return a class with a child of MapLayers" do
      MapLayers::OpenLayers::Test.name.must_equal "MapLayers::OpenLayers::Test"
    end

    it "should return a class with a little child of MapLayers" do
      MapLayers::OpenLayers::Test::Toto.name.must_equal "MapLayers::OpenLayers::Test::Toto"
    end
  end

end
