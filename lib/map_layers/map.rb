module MapLayers

  GOOGLE = OpenLayers::Layer::Google.new("Google Street")
  GOOGLE_SATELLITE = OpenLayers::Layer::Google.new("Google Satelite", {:type => :G_SATELLITE_MAP})
  GOOGLE_HYBRID = OpenLayers::Layer::Google.new("Google Hybrid", {:type => :G_HYBRID_MAP})
  GOOGLE_PHYSICAL = OpenLayers::Layer::Google.new("Google Physical", {:type => :G_PHYSICAL_MAP})
  VE_ROAD = OpenLayers::Layer::VirtualEarth.new("Virtual Earth Raods", {:type => JsExpr.new('VEMapStyle.Road')})
  VE_AERIAL = OpenLayers::Layer::VirtualEarth.new("Virtual Earth Aerial", {:type => JsExpr.new('VEMapStyle.Aerial')})
  VE_HYBRID = OpenLayers::Layer::VirtualEarth.new("Virtual Earth Hybrid", {:type => JsExpr.new('VEMapStyle.Hybrid')})
  YAHOO =  OpenLayers::Layer::Yahoo.new("Yahoo Street")
  YAHOO_SATELLITE = OpenLayers::Layer::Yahoo.new("Yahoo Satelite", {:type => :YAHOO_MAP_SAT})
  YAHOO_HYBRID = OpenLayers::Layer::Yahoo.new("Yahoo Hybrid", {:type => :YAHOO_MAP_HYB})
  MULTIMAP = OpenLayers::Layer::MultiMap.new("MultiMap")
  OSM_MAPNIK = OpenLayers::Layer::OSM.new("OpenStreetMap")
  OSM_TELASCIENCE = OpenLayers::Layer::WMS.new("OpenStreetMap",
    [
      "http://t1.hypercube.telascience.org/tiles?",
      "http://t2.hypercube.telascience.org/tiles?",
      "http://t3.hypercube.telascience.org/tiles?",
      "http://t4.hypercube.telascience.org/tiles?"
    ],
    {:layers => 'osm-4326', :format => 'image/png' } )
  GEOPOLE_OSM = OpenLayers::Layer::TMS.new("Geopole Street Map",
    "http://tms.geopole.org/",
    {:layername => 'geopole_street', :type => 'png', :maxResolution => 0.703125,
     :attribution => 'Map data <a href="http://creativecommons.org/licenses/by-sa/2.0/">CCBYSA</a> 2009 <a href="http://openstreetmap.org/">OpenStreetMap.org</a>'})
  NASA_GLOBAL_MOSAIC = OpenLayers::Layer::WMS.new("NASA Global Mosaic",
    [
      "http://t1.hypercube.telascience.org/cgi-bin/landsat7",
      "http://t2.hypercube.telascience.org/cgi-bin/landsat7",
      "http://t3.hypercube.telascience.org/cgi-bin/landsat7",
      "http://t4.hypercube.telascience.org/cgi-bin/landsat7"
    ],
    {:layers => 'landsat7'} )
  BLUE_MARBLE_NG = OpenLayers::Layer::WMS.new("Blue Marble NG",
    "http://wms.telascience.org/cgi-bin/ngBM_wms",
    {:layers => 'world_topo_bathy'} )
  METACARTA_VMAP0 = OpenLayers::Layer::WMS.new("OpenLayers WMS",
    "http://labs.metacarta.com/wms/vmap0",
    {:layers => 'basic'} )
  WORLDWIND = OpenLayers::Layer::WorldWind.new("World Wind LANDSAT",
    "http://worldwind25.arc.nasa.gov/tile/tile.aspx", 2.25, 4, {:T => "105"}, {:tileSize => OpenLayers::Size.new(512,512)})
  WORLDWIND_URBAN = OpenLayers::Layer::WorldWind.new("World Wind Urban",
    "http://worldwind25.arc.nasa.gov/tile/tile.aspx", 0.8, 9, {:T => "104"}, {:tileSize => OpenLayers::Size.new(512,512)})
  WORLDWIND_BATHY = OpenLayers::Layer::WorldWind.new("World Wind Bathymetry",
    "http://worldwind25.arc.nasa.gov/tile/tile.aspx", 36, 4, {:T => "bmng.topo.bathy.200406"}, {:tileSize => OpenLayers::Size.new(512,512)})


#      map.setCenter(new OpenLayers.LonLat(77.6, 21.31), 4);


  #Map viewer main class
  class Map
    include JsWrapper
    attr_reader :container, :variables

    def initialize(map, options = {}, &block)
      @container = map
      @handler = "#{map}_handler"
      @variable = map
      @variables = [map] 
      @options = {:theme => false}.merge(options)
      @js = JsGenerator.new(:included => true)
#      @icons = []
      yield(self, @js) if block_given?
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
      no_declare = options[:no_declare]
      no_global = options[:no_global]

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
      @js << assign_to(@variable)
    end
  end

end
