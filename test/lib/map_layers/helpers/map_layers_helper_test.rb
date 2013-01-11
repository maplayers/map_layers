require 'test_helper'

describe MapLayers::ViewHelper do
  before do

    ActionView::Base.send(:include, MapLayers::ViewHelper)
    @view = ActionView::Base.new
  end

  it "should integrate with ActionView::Base" do
    [:map_layers_includes, :map_layers_script, :map_layers_container, :map_layers_localize_form_tag].each do |method|
      @view.respond_to?(method).must_equal true
    end
  end

end
