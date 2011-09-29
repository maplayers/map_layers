module MapLayers
 
  # KML Server methods
  module KML
    
    # Publish layer in KML format
    def kml
      rows = map_layers_config.model.find(:all, :limit => KML_FEATURE_LIMIT)
      @features = rows.collect do |row|
        if map_layers_config.geometry
          Feature.from_geom(row.send(map_layers_config.text), row.send(map_layers_config.geometry))
        else
          Feature.new(row.send(map_layers_config.text), row.send(map_layers_config.lon), row.send(map_layers_config.lat))
        end
      end
      @folder_name = map_layers_config.model_id.to_s.pluralize.humanize
      logger.info "MapLayers::KML: returning #{@features.size} features"
      render :inline => KML_XML_ERB, :content_type => "text/xml"
    rescue Exception => e
      logger.error "MapLayers::KML: returning no features - Caught exception '#{e}'"
      render :text => KML_EMPTY_RESPONSE, :content_type => "text/xml"
    end
    
    protected

    KML_FEATURE_LIMIT = 1000
    
    KML_XML_ERB = <<EOS # :nodoc:
<?xml version="1.0" encoding="UTF-8" ?>
<kml xmlns="http://earth.google.com/kml/2.0">
  <Document>
  <Folder><name><%= @folder_name %></name>
  <% for feature in @features -%>
    <Placemark>
      <description><%= feature.text %></description>
      <Point><coordinates><%= feature.x %>,<%= feature.y %></coordinates></Point>
    </Placemark>
  <% end -%>
  </Folder>
  </Document>
</kml>
EOS

    KML_EMPTY_RESPONSE = <<EOS # :nodoc:
<?xml version="1.0" encoding="UTF-8" ?>
<kml xmlns="http://earth.google.com/kml/2.0">
  <Document>
  </Document>
</kml>
EOS    
  end

end
