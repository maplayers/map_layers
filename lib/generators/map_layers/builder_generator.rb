module MapLayers
  module Generators
    class BuilderGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
Description:
    Copies Piktur configuration file to your application's initializer directory.
DESC

      class_option :builder_type, :type => :string, :aliases => "-b", :desc => "Builder engine to generate. Available options are 'kml', 'georss' and 'wps' .", :default => "wps"

      # rails generate map_layers:builder --builder_type kml
      # rails generate map_layers:builder -b kml
      def copy_builder_file
        case builder_type = options[:builder_type].to_s
          when "kml", "georss", "gpx"
            create_builder_for(builder_type)
          else
            create_builder_for(:kml)
        end
      end

      protected

      def create_builder_for(engine)
        # TODO : add more builders
        engine = :kml
        template "index.#{engine}.builder", "app/views/map_layers/index.#{engine}.builder"
      end
    end
  end
end
