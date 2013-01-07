module MapLayers
  # Provides methods to generate HTML tags and JavaScript code
  module ViewHelpers
    # Insert javascript include tags
    #
    # * options[:google] with GMAPS Key: Include Google Maps
    # * options[:multimap] with MultiMap Key: Include MultiMap
    # * options[:virtualearth]: Include VirtualEarth
    # * options[:yahoo] with Yahoo appid: Include Yahoo! Maps
    # * options[:proxy] with name of controller with proxy action. Defaults to current controller.
    def map_layers_includes(map_builder, options = {}, &block)
#      options.assert_valid_keys(:google, :multi_map, :osm, :virtual_earth, :yahoo,
#                                :proxy, :img_path,
#                                :onload)
      ml_script = options[:map_layer_script] || nil

      layers_added = map_builder.map.layers

      scripts = []
      scripts << "http://maps.google.com/maps/api/js?v=3&sensor=false" if options.has_key?(:google) || layers_added.include?(:google)
      scripts << "http://clients.multimap.com/API/maps/1.1/#{options[:multimap]}" if options.has_key?(:multi_map) || layers_added.include?(:multi_map)
      scripts << "http://dev.virtualearth.net/mapcontrol/v3/mapcontrol.js" if options.has_key?(:virtual_earth) || layers_added.include?(:virtual_earth)
      scripts << "http://api.maps.yahoo.com/ajaxymap?v=3.0&appid=#{options[:yahoo]}" if options.has_key?(:yahoo) || layers_added.include?(:yahoo)

      scripts << ml_script unless ml_script.nil?

      html = []
      scripts.each { |script| html << javascript_include_tag(script) }
      html << javascript_tag(map_layers_script(map_builder, options, &block)) if ml_script.nil?

      html.join("\n").html_safe
    end

    def map_layers_script(map_builder, options = {}, &block)
      onload = options[:onload] || false

      img_path = options[:img_path] || '/assets/OpenLayers/'
      rails_relative_url_root = controller.config.relative_url_root
      img_path=(Pathname(rails_relative_url_root||"") +img_path).cleanpath.to_s
      proxy = options[:proxy] || controller.controller_name

      scripts = []
      scripts << "OpenLayers.ImgPath='#{img_path}/';"
      scripts << "OpenLayers.ProxyHost='/#{proxy}/proxy?url=';"
      scripts << map_builder.to_js
      scripts << %Q[$(document).ready(function() { map_layers_init_#{map_builder.map.container}(); });] if onload
      scripts << (capture(&block) % { :map_handler => map_builder.map_handler.container, :map => map_builder.map.container  } rescue "alert('error');") if block_given?

      scripts.join("\n").html_safe
    end

    def map_layers_container(map_builder, options = {}, &block)
      include_loading = options[:include_loading] || false

      klass = %w(map_container)
      klass << options[:class] unless options[:class].nil?
      content_tag(:div, :class => klass.join(" ")) do
        content = content_tag(:div, '', :id => map_builder.map.container)
        content << content_tag(:div, '', :class => 'loading') if include_loading
        content << capture(&block) if block_given?
        content
      end
    end

    def map_layers_localize_form_tag(url_for_options = {}, options = {}, &block)
      klass = options[:class] || ''
      map_layers_options = options.merge(:remote => true, :class => [klass, 'map_layers', 'localize'].reject { |c| c.empty? }.join(' '))
      form_tag(url_for_options, map_layers_options, &block)
    end

  end
end
