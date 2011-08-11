require File.expand_path('../../spec_helper', __FILE__)

describe MapLayers do

  describe ".const_missing" do

    it "should return a class with a child of MapLayers" do
      OpenLayers::Test.name.should == "OpenLayers::Test"
    end

    it "should return a class with a little child of MapLayers" do
      OpenLayers::Test::Toto.name.should == "OpenLayers::Test::Toto"
    end
    
  end

end
