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
    def map_layers_includes(options = {})
      options.assert_valid_keys(:google, :multimap, :openstreetmap, :virtualearth, :yahoo, :proxy,:img_path)
      html = []
      if options.has_key?(:google)
        #html << "<script type=\"text/javascript\" src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{options[:google]}\"></script>"
        html << "<script type=\"text/javascript\" src=\"http://maps.google.com/maps/api/js?v=3&amp;sensor=false\"></script>"
      end
      if options.has_key?(:multimap)
        html << "<script type=\"text/javascript\" src=\"http://clients.multimap.com/API/maps/1.1/#{options[:multimap]}\"></script>"
      end
      if options.has_key?(:virtualearth)
        html << "<script type=\"text/javascript\" src=\"http://dev.virtualearth.net/mapcontrol/v3/mapcontrol.js\"></script>"
      end
      if options.has_key?(:yahoo)
        html << "<script type=\"text/javascript\" src=\"http://api.maps.yahoo.com/ajaxymap?v=3.0&appid=#{options[:yahoo]}\"></script>"
      end
      img_path = '/assets/OpenLayers/'
      if options.has_key?(:img_path)
        img_path = options[:img_path]
      end
      if defined?( RAILS_ROOT)
        rails_env = RAILS_ENV
        rails_root = RAILS_ROOT
        rails_relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']
      else
        rails_env = Rails.env
        rails_root = Rails.root
        rails_relative_url_root = controller.config.relative_url_root
      end
#      if rails_env == "development" && File.exist?(File.join( rails_root, 'public/javascripts/lib/OpenLayers.js'))
#        html << '<script src="/javascripts/lib/Firebug/firebug.js"></script>'
#        html << '<script src="/javascripts/lib/OpenLayers.js"></script>'
#      else
#        html << javascript_include_tag('OpenLayers')
#      end


      #html << stylesheet_link_tag("map")
      img_path=(Pathname(rails_relative_url_root||"") +img_path).cleanpath.to_s
      html << javascript_tag("OpenLayers.ImgPath='"+ img_path  + "/';")
      proxy = options.has_key?(:proxy) ? options[:proxy] : controller.controller_name
      html << javascript_tag("OpenLayers.ProxyHost='/#{proxy}/proxy?url=';")

      html.join("\n").html_safe
    end

    def map_layers_container(map, options = {})
      #<div class="map_container default_size">
      #  <div id="map"></div>
      #</div>
      klass = %w(map_container)
      klass << options[:class] unless options[:class].nil?
      content_tag(:div, :class => klass.join(" ")) do
        content_tag(:div, '', :id => map.container)
      end
    end

  end
end
