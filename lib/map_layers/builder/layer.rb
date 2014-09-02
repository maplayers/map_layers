module MapLayers
  module Builder
    class Layer
      attr_reader :name, :options

      def initialize(name, options = {})
        @name = name
        @options = options
      end
    end
  end
end
