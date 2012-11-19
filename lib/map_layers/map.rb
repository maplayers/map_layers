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

    def initialize(map, options = {}, &block)
      @container = map
      @variable = map
      @options = {:theme => false}.merge(options)
      @js = JsGenerator.new
#      @icons = []
      yield(self, @js) if block_given?
    end

    #Outputs in JavaScript the creation of a OpenLayers.Map object
    def create
      "new OpenLayers.Map('#{@container}', #{JsWrapper::javascriptify_variable(@options)})"
    end

    def add_icon(name, url, options = {})
      name_js = name.to_s.parameterize
      "#{name_js} = #{create_js_icon(url, options)}"
    end

    def create_js_icon(url, options = {})
      height = options[:height] || nil
      width = options[:width] || nil
      offset_height = options[:offset_height] || -height.to_i
      offset_width = options[:offset_width] || -width.to_i/2

      marker_sizes = (height.nil? || width.nil?) ? nil : [width, height]
      marker_offset = (offset_height.nil? || offset_width.nil?) ? nil : [offset_width, offset_height]

      marker_offset = nil if marker_sizes.nil?

      opts = [ "'#{url}'" ]
      opts << "new OpenLayers.Size(#{marker_sizes[0]}, #{marker_sizes[1]})" unless marker_sizes.nil?
      opts << "new OpenLayers.Pixel(#{marker_offset[0]}, #{marker_offset[1]})" unless marker_offset.nil?

      "new OpenLayers.Icon(#{opts.join(',')})"
    end

    def register_event(marker, event, &block)
      "#{marker}.events.register('mousedown', marker, function(evt) { alert(this.icon.url); OpenLayers.Event.stop(evt) })"
    end

    def create_markers(name, options = {}, &block)
      markers = Markers.new(@container, name, options)
      yield markers if block_given?
      markers.to_html.html_safe
    end

    #Outputs the initialization code for the map
    def to_html(options = {})
      no_script_tag = options[:no_script_tag]
      no_declare = options[:no_declare]
      no_global = options[:no_global]

      html = ""
      html << "<script defer=\"defer\" type=\"text/javascript\">\n" if !no_script_tag
      #put the functions in a separate javascript file to be included in the page
      html << "var #{@variable};\n" if !no_declare and !no_global

      if !no_declare and no_global
        html << "#{declare(@variable)}\n"
      else
        html << "#{assign_to(@variable)}\n"
      end
      html << @js.to_s
      html << "</script>\n" if !no_script_tag

      html.html_safe
    end
  end

  class Markers
    attr_reader :map, :name, :title, :markers

    def initialize(map, name, options = {})
      name_js = name.to_s.parameterize
      title = options[:title] || name_js

      @map, @name, @title = map, name_js, title
      @markers = []
    end

    def add_marker(lat, lng, options = {}, &block)
      puts "ADDING : #{lat} #{lng}"
      marker = Marker.new(map, "#{name}_marker#{@markers.count}", lat, lng, options)
      yield marker if block_given?
      @markers << marker
    end

    def to_html
      html = ["#{name} = new OpenLayers.Layer.Markers(\"#{title}\")"]
      #html << self.instance_eval(&block) if block_given?
      @markers.each do |marker|
        html << marker.to_html
        html << "#{name}.addMarker(#{marker.name})"
      end
      html << "#{map}.addLayer(#{name})"
      html.join(";\n")
    end

  end

  class Marker
    attr_reader :map, :name, :lat, :lng, :projection, :icon, :events

    def initialize(map, name, lat, lng, options = {})
      name_js = name.to_s.parameterize
      without_transform = options[:without_transform] || false
      projection = options[:projection] || without_transform ? nil : "EPSG:4326"
      @icon = options[:icon] || nil
      @map, @name, @projection = map, name_js, projection
      @lat, @lng = lat, lng
      @events = []
    end

    def register_event(event, fct)
      @events << {:event => event, :fct => fct} #capture(&block)}
    end

    def to_html
      transform = projection.nil? ? "" :  ".transform(new OpenLayers.Projection(\"#{projection}\"), #{map}.getProjectionObject())" 

      html = []
      html << "#{name} = new OpenLayers.Marker( new OpenLayers.LonLat(#{lat}, #{lng})#{transform}#{", #{icon}.clone()" unless icon.nil?} )"
      @events.each do |evt|
        html << "#{name}.events.register('#{evt[:event]}', #{name}, #{evt[:fct]})"
      end
      html.join(";\n")
    end
  end

end
