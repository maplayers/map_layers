require 'spec_helper'

describe MapLayers do

  describe ".const_missing" do

    it "should return the class MapLayers::Layer::Google for GOOGLE" do
      MapLayers::GOOGLE.class.to_s.should == "OpenLayers::Layer::Google"
    end
    
  end

end
