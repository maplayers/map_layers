module MapLayers

#      map.setCenter(new OpenLayers.LonLat(77.6, 21.31), 4);


  #Map viewer main class
  class Map
    include JsWrapper
    attr_reader :container, :variables, :layers

    def initialize(map, options = {}, &block)
      @container = map
      @handler = "#{map}_handler"
      #@variable = map
      @layers = []
      @variables = [map] 
      @options = {:theme => false}.merge(options)
      @js = JsGenerator.new(:included => true)
#      @icons = []
      yield(self, @js) if block_given?
    end

    # add_layer method which save the name of layer included before calling the javascript action
    def add_layer(*args)
      type = args.first.class.to_s.split(":").last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym rescue nil
      @layers << type unless type.nil? || layers.include?(type)

      # call default javascript action
      method_missing('add_layer', *args)
    end

    #Outputs in JavaScript the creation of a OpenLayers.Map object
    def create
      "new OpenLayers.Map('#{@container}', #{JsWrapper::javascriptify_variable(@options)})"
    end

    def create_vector_layer(name, url, options = {})
      projection = options[:projection] || JsExpr.new("#{@container}.displayProjection")
      format = options[:format] || nil
      protocol = url.nil? ? {} : {
          :strategies => [OpenLayers::Strategy::Fixed.new], #, OpenLayers::Strategy::Cluster.new],
          :protocol => OpenLayers::Protocol::HTTP.new({
            :url => url,
            :format => format
          })
        }

      OpenLayers::Layer::Vector.new(name, {
          :projection => projection
        }.merge(protocol))
    end

    def add_map_handler(layer, options = {})
      default_control = options[:default_control] || 'select'
      default_control = 'select' unless %w(select point path polygon drag).include?(default_control)

      js = JsGenerator.new(:included => true)

      js.assign(@handler, JsExpr.new("new MapLayers.SimpleMapHandler(#{@container})"), :declare => true)
      js << JsVar.new(@handler).initializeControls(layer)
      js << JsVar.new(@handler).toggleControl(layer, default_control)

      js.to_s.html_safe
    end


    def replace_vector_layer(name, url, options = {})
      js = JsGenerator.new(:included => true)
      #map_handler.destroyLayer('pikts');
      js << JsVar.new(@handler).destroyLayer(name)
      js << add_vector_layer(name, url, options)

      js.to_s.html_safe
    end

    def add_vector_layer(name, url, options = {})
      no_global = options[:no_global]
      no_controls = options[:no_controls]
      format = options[:format] || :kml
      layer_name = name.parameterize

      js = JsGenerator.new(:included => true)

      frmt = case format
      when :georss
      else # :kml is the default
        OpenLayers::Format::KML.new({:extractStyles => true, :extractAttributes => true})
      end

      layer = create_vector_layer(name, url, options.merge(
          :format => frmt))

      @variables << layer_name

      js.assign(layer_name, layer) #, :declare => !no_global)
      js << JsVar.new(@container).add_layer(JsVar.new(layer_name))
      #js << add_map_handler(name, options) unless no_controls

      js.to_s.html_safe
    end

    #Outputs the initialization code for the map
    def to_js(options = {})
#      no_declare = options[:no_declare]
#      no_global = options[:no_global]

      #html = ""
      #put the functions in a separate javascript file to be included in the page

      #@variables.each do |variable|
#        html << "var #{@variable};\n" if !no_declare and !no_global
#puts "here !! variable #{@variable}"
#puts "here !! declare #{declare(@variable)}"
#puts "here !! assign #{assign_to(@variable)}"
#
#        if !no_declare and no_global
#          html << "#{declare(@variable)}\n"
#        else
#          html << "#{assign_to(@variable)}\n"
#        end
      #end
      #@js << assign_to(@variable)
      @js << assign_to(@container)
    end
  end

end
