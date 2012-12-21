module MapLayers
  class MapHandler
    include JsWrapper
    attr_reader :variables, :container

    def initialize(map, options = {}, &block)
      default_control = options[:default_control] || 'select'
      default_control = 'select' unless %w(select point path polygon drag).include?(default_control)

      @map = map.container
      @container = options[:name] || "#{map.container}_handler"

      # js variables
      @variables = [@container] 

      #@js = JsGenerator.new
      @js = JsGenerator.new(:included => true)

      yield(self, @js) if block_given?
    end

    #Outputs in JavaScript the creation of a OpenLayers.Map object
    def create
      #"new OpenLayers.Map('#{@container}', #{JsWrapper::javascriptify_variable(@options)})"
      JsExpr.new("new MapLayers.SimpleMapHandler(#{@map})")
    end

    #Outputs the initialization code for the map
    def to_js(options = {})
      @js << assign_to(@container)
    end

  end
end
