require File.expand_path('../../spec_helper', __FILE__)

describe MapLayers do

  describe ".const_missing" do

    it "should return a class with a child of MapLayers" do
      MapLayers::Test.name.should == "MapLayers::Test"
    end

    it "should return a class with a little child of MapLayers" do
      MapLayers::Test::Toto.name.should == "MapLayers::Test::Toto"
    end
    
  end

end
