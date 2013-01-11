require 'pp'

module MapLayers
  module JsExtension

    #The module where all the Ruby-to-JavaScript conversion takes place.
    #Based on Ym4r::GmPlugin::MappingObject from Guilhem Vellut
    module JsWrapper
      #The name of the variable in JavaScript space.
      attr_reader :variable

      UNDEFINED = 'undefined'

      #Creates javascript code for missing methods + takes care of listeners
      def method_missing(name,*args)
        #str_name = name.to_s
        #args.collect! do |arg|
        #  JsWrapper.javascriptify_variable(arg)
        #end
pp "NAME : #{name} to_javascript #{to_javascript}"
puts args.inspect
#puts args.join(',')
        #JsExpr.new("#{to_javascript}.#{JsWrapper.javascriptify_method(str_name)}(#{args.join(",")})")
        javascriptify_method_call(name.to_s, *args)
      end

      # Creates javascript code for method calls
      def javascriptify_method_call(name,*args)
        args.collect! do |arg|
          JsWrapper.javascriptify_variable(arg)
        end
        JsExpr.new("#{to_javascript}.#{JsWrapper.javascriptify_method(name.to_s)}(#{args.join(",")})")
      end

      #Creates javascript code for array or hash indexing
      def [](index) #index could be an integer or string
        return JsExpr.new("#{to_javascript}[#{JsWrapper.javascriptify_variable(index)}]")
      end

      #Transforms a Ruby object into a JavaScript string : JsWrapper, String, Array, Hash and general case (using to_s)
      def self.javascriptify_variable(arg)
#        if arg.is_a?(JsWrapper)
#          arg.to_javascript
#        elsif arg.is_a?(String)
#          "\'#{JsWrapper.escape_javascript(arg)}\'"
#        elsif arg.is_a?(Array)
#          "[" + arg.collect{ |a| JsWrapper.javascriptify_variable(a)}.join(",") + "]"
#        elsif arg.is_a?(Hash)
#          "{" + arg.to_a.collect do |v|
#            "#{JsWrapper.javascriptify_method(v[0].to_s)} : #{JsWrapper.javascriptify_variable(v[1])}"
#          end.join(",") + "}"
#        elsif arg.nil?
#          UNDEFINED
#        else
#          arg.to_s
#        end
        case arg
          when JsWrapper, JsExpr, JsVar
#pp "JAVASCRIPTIFY : JS"
            arg.to_javascript
          when String
#pp "JAVASCRIPTIFY : STRING"
            "\'#{JsWrapper.escape_javascript(arg)}\'"
          when Array
            "[" + arg.collect{ |a| JsWrapper.javascriptify_variable(a)}.join(",") + "]"
          when Hash
            "{" + arg.to_a.collect { |v| "#{JsWrapper.javascriptify_method(v[0].to_s)} : #{JsWrapper.javascriptify_variable(v[1])}" }.join(",") + "}"
          when NilClass
            UNDEFINED
          else
#pp "JAVASCRIPTIFY : ELSE"
            arg.to_s
        end
      end

      #Escape string to be used in JavaScript. Lifted from rails.
      def self.escape_javascript(javascript)
        javascript.gsub(/\r\n|\n|\r/, "\\n").gsub("\'") { |m| "\\#{m}" }
      end

      #Transform a ruby-type method name (like add_overlay) to a JavaScript-style one (like addOverlay).
      def self.javascriptify_method(method_name)
        method_name.gsub(/_(\w)/){|s| $1.upcase}
      end

      #
      #def var(*variables)
      #  "var #{variables.join(',')}"
      #end

      #Declares a Mapping Object bound to a JavaScript variable of name +variable+.
      def declare(variable, options = {})
        assign_variable = options[:assign] || false
        #@variable = variable
        #"var #{@variable} = #{create};"
        #var(assign_variable ? assign_to(variable) : variable)
        JsExpr.new("var #{assign_variable ? assign_to(variable) : variable}")
      end

      #declare with a random variable name
      def declare_random(init, options = {})
        s = init.clone
        6.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
        declare(s, options)
      end

      #Checks if the MappinObject has been declared
      def declared?
        !@variable.nil?
      end

      #Assign the +value+ to the +property+ of the JsWrapper
      def set_property(property, value)
        "#{to_javascript}.#{JsWrapper.javascriptify_method(property.to_s)} = #{JsWrapper.javascriptify_variable(value)}"
      end

      #Returns the code to get a +property+ from the JsWrapper
      def get_property(property)
        JsExpr.new("#{to_javascript}.#{JsWrapper.javascriptify_method(property.to_s)}")
      end

      #Returns a Javascript code representing the object
      def to_javascript
pp "to_javascript"
        ret = @variable.nil? ? create : @variable
pp "#{@variable} --> #{ret}"
        ret
      end

      #To cheat JavaScriptGenerator::GeneratorMethods::javascript_object_for
      def to_json(options = {})
        to_javascript
      end

      #Creates a Mapping Object in JavaScript.
      #To be implemented by subclasses if needed
      def create
      end

      #Binds a Mapping object to a previously declared JavaScript variable of name +variable+.
      def assign_to(variable)
        @variable = variable
        "#{@variable} = #{create}"
      end

      def set_variable(variable)
        @variable = variable
      end

      def get_variable
        @variable
      end
    end

    #A valid JavaScript expression that has a value.
    class JsExpr
      include JsWrapper
      attr_reader :expr

      def initialize(expr)
        @expr = expr
      end
      #Returns the javascript expression contained in the object.
      def create
        expr
      end

      def to_ary
pp "to_ary called"
#raise 'toto'
        [create]
      end

      def to_s
pp "to_s called"
pp expr.class
pp expr
        expr.to_s
      end
      def to_str
        to_s
      end
      #alias_method :to_s, :create
      #alias_method :to_str, :to_s

      #UNDEFINED = JsExpr.new(JsWrapper::UNDEFINED)
    end


    #Used to bind a ruby variable to an already existing JavaScript one.
    class JsVar
      include JsWrapper
      attr_reader :variable, :value

      alias_method :to_s, :variable
      #alias_method :to_str, :create

      def initialize(variable)
        @variable = variable
      end

      def assign(val)
        #@value = JsWrapper::javascriptify_variable(val)
        @value = val
        create
      end

      def create
        JsExpr.new("#{@variable} = #{JsWrapper::javascriptify_variable(value)}")
      end
    end


    #Minimal Wrapper around a Javascript class
    class JsClass
      include JsWrapper

      def self.const_missing(sym)
        if self.const_defined?(sym)
          konst = self.const_get(sym)
        else
          konst = self.const_set(sym, Class.new(JsClass))
        end
      end

      def initialize(*args)
        @args = args
      end

      def create
        jsclass = self.class.to_s.split(/::/)[1..-1]
        jsclass.insert(0, 'OpenLayers') unless jsclass[0] == 'OpenLayers'
        args = @args.collect{ |arg| JsWrapper.javascriptify_variable(arg) }
        JsExpr.new("new #{jsclass.join('.')}(#{args.join(',')})")
      end

    end

    class JsGenerator # :nodoc:
      attr_reader :lines
      def initialize(options = {})
        @included = options[:included] || false
        @lines = []
      end
      def <<(javascript)
        #@lines << (javascript.is_a?(JsWrapper) ? javascript.to_javascript : javascript)
        case javascript
          when JsGenerator
            @lines.concat(javascript.lines)
          # OPTIMIZE: why arrays ?
          #when Array
          #  @lines.concat(javascript)
          when JsWrapper, JsVar, JsExpr
#@lines << "TYPE JS : #{javascript.inspect}"
            #@lines << "--> #{javascript.to_javascript} <--; // js"
            @lines << "#{javascript.to_javascript};"
          else
#@lines << "TYPE ELSE : #{javascript.class}"
            #@lines << "==> #{javascript} <==; // string"
            @lines << javascript
        end
      end
      def assign(variable, value)
        self << "#{variable} = #{JsWrapper::javascriptify_variable(value)}"
      end
      def to_s
        #"#{@lines.join(";\n")}#{@included ? '' : ";\n"}"
        @lines.join("\n")
      end
    end

  end
end
