# rails generate map_layers:config -b kml
module MapLayers
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
Description:
    Copies Piktur configuration file to your application's initializer directory.
DESC

      class_option :builder_type, :type => :string, :aliases => "-b", :desc => "Builder engine to generate. Available options are 'kml', 'georss' and 'wps' .", :default => "wps"

      def copy_config_file
        case builder_type = options[:builder_type].to_s
          when "kml", "georss"
            create_builder_for(builder_type)
          else
            create_builder_for(:wps)
        end
      end

      protected

      def create_builder_for(engine)
        engine = :kml
        #template 'map_layers_config.rb', "tmp/#{engine}_config.rb"
        template "index.#{engine}.builder", "tmp/#{engine}_config.rb"
      end
    end
  end
end
