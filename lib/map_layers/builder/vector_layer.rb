module MapLayers
  module Builder
    class VectorLayer < Layer
      attr_reader :format, :url

      def initialize(name, options = {})
        super(name, options)
        @format = options[:format] || :kml
        @url = options[:url]
      end
    end
  end
end
