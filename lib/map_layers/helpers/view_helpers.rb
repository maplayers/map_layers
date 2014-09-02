module MapLayers

  EXTERNAL_SCRIPTS = {
    :google => "https://maps.googleapis.com/maps/api/js?sensor=false",
    :multi_map => "http://clients.multimap.com/API/maps/1.1/%{multimap}",
    :virtual_earth => "http://dev.virtualearth.net/mapcontrol/v3/mapcontrol.js",
    :yahoo => "http://api.maps.yahoo.com/ajaxymap?v=3.0&appid=%{yahoo}"
  }

  # Provides methods to generate HTML tags and JavaScript code
  module ViewHelper
    # Insert javascript include tags
    #
    # * options[:google] with GMAPS Key: Include Google Maps
    # * options[:multi_map] with MultiMap Key: Include MultiMap
    # * options[:virtual_earth]: Include VirtualEarth
    # * options[:yahoo] with Yahoo appid: Include Yahoo! Maps
    # * options[:proxy] with name of controller with proxy action. Defaults to current controller.
    def map_layers_includes(map_builder, options = {}, &block)
      ml_script = options[:map_layer_script] || nil

      #layers_added = map_builder.js_builder.js_map.layers
      layers_added = map_builder.js_builder.js_map.layers

      # keep a trace of loaded layers to avoid double loading
      @map_layers_loaded_layers ||= []

      map_options = options.dup.keep_if { |key| EXTERNAL_SCRIPTS.has_key?(key) }

      # page return array
      html = []

      # external scripts array
      scripts = []

      # load external scripts
      EXTERNAL_SCRIPTS.each do |key, value|
        if options.has_key?(key) || layers_added.include?(key)
          unless @map_layers_loaded_layers.include?(key)
            # OPTIMIZE: provide a better error message than KeyError exception
            scripts << (value % map_options).html_safe #rescue nil
            @map_layers_loaded_layers << key
          else
            html << "<!-- #{key.to_s} scripts for map_layers already loaded -->"
          end
        end
      end

      # load optional map_layers script
      scripts << ml_script unless ml_script.nil?

      # add external scripts to page
      scripts.compact.each { |script| html << javascript_include_tag(script) }

      # add default map_layers script to page
      html << javascript_tag(map_layers_script(map_builder, options, &block)) if ml_script.nil?

      html.join("\n").html_safe
    end

    ##
    # Load map_layers script
    #
    def map_layers_script(map_builder, options = {}, &block)
      onload = options[:onload] || false

      img_path = options[:img_path] || '/assets/openlayers/img'
      unless controller.nil?
        rails_relative_url_root = controller.config.relative_url_root
        img_path=(Pathname(rails_relative_url_root||"") +img_path).cleanpath.to_s
        proxy = options[:proxy] || controller.controller_name
      end

      js_code = (capture(&block) % { :map_handler => map_builder.js_builder.js_handler.variable, :map => map_builder.js_builder.js_map.variable  } rescue "alert('error');") if block_given?

      scripts = []
      scripts << "OpenLayers.ImgPath='#{img_path}/';"
      scripts << "OpenLayers.ProxyHost='/#{proxy}/proxy?url=';" unless proxy.nil?
      scripts << map_builder.js_builder.to_js(js_code)
      scripts << %Q[$(document).ready(function() { map_layers_init_#{map_builder.js_builder.js_map.variable}(); });] if onload

      scripts.join("\n").html_safe
    end


    ##
    # Output map_layers div container, where the map will be printed
    #
    def map_layers_container(map_builder, options = {}, &block)
      include_loading = options[:include_loading] || false

      klass = %w(map_container)
      klass << options[:class] unless options[:class].nil?
      content_tag(:div, :class => klass.join(" ")) do
        content = content_tag(:div, '',
                              :id => map_builder.js_builder.js_map.variable,
                              :class => map_builder.js_builder.js_map.layers.map { |l| "maplayers-#{l}" }.join(' ')
                             )
        content << content_tag(:div, '', :class => 'loading') if include_loading
        content << capture(&block) if block_given?
        content
      end
    end

    def map_layers_form_fields_container(map_builder = nil, options = {}, &block)
      #  <div class="map_info" data-map="<%= local_assigns.has_key?(:map) ? map : 'map' %>">
      html_options = {:class => 'map_info'}
      html_options.merge!({:data => { :map => map_builder.js_builder.js_map.variable }}) unless map_builder.nil?

      content_tag(:div, html_options) do
        capture(&block) if block_given?
      end
    end

    ##
    # OPTIMIZE: localize form
    #
    def map_layers_localize_form_tag(url_for_options = {}, options = {}, &block)
      klass = options[:class] || ''
      map_layers_options = options.merge(:remote => true, :class => [klass, 'map_layers', 'localize'].reject { |c| c.empty? }.join(' '))
      form_tag(url_for_options, map_layers_options, &block)
    end

  end
end
