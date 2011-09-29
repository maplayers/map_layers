module MapLayers

  # WFS Server methods
  module WFS
    
    WGS84 = 4326
    
    # Publish layer in WFS format
    def wfs
      minx, miny, maxx, maxy = extract_params
      model = map_layers_config.model
      if map_layers_config.geometry
        db_srid = model.columns_hash[map_layers_config.geometry.to_s].srid
        if db_srid != @srid && !db_srid.nil? && db_srid != -1
          #Transform geometry from db_srid to requested srid (not possible for undefined db_srid)
          geom = "Transform(#{geom},#{@srid}) AS #{geom}"
        end
        
        spatial_cond = if model.respond_to?(:sanitize_sql_hash_for_conditions)
          model.sanitize_sql_hash_for_conditions(map_layers_config.geometry => [[minx, miny],[maxx, maxy], db_srid])
        else # Rails < 2
          model.sanitize_sql_hash(map_layers_config.geometry => [[minx, miny],[maxx, maxy], db_srid])
        end
        #spatial_cond = "Transform(#{spatial_cond}, #{db_srid}) )" Not necessary: bbox is always WGS84 !?

        rows = model.find(:all, :conditions => spatial_cond, :limit => @maxfeatures)
        @features = rows.collect do |row|
          Feature.from_geom(row.send(map_layers_config.text), row.send(map_layers_config.geometry.to_s))
        end
      else
        rows = model.find(:all, :limit => @maxfeatures)
        @features = rows.collect do |row|
          Feature.new(row.send(map_layers_config.text), row.send(map_layers_config.lon), row.send(map_layers_config.lat))
        end
      end
      logger.info "MapLayers::WFS: returning #{@features.size} features"
      render :inline => WFS_XML_ERB, :content_type => "text/xml"
    rescue Exception => e
      logger.error "MapLayers::WFS: returning no features - Caught exception '#{e}'"
      render :text => WFS_EMPTY_RESPONSE, :content_type => "text/xml"
    end
    
    protected

    WFS_FEATURE_LIMIT = 1000
    
    def extract_params # :nodoc:
      @maxfeatures = (params[:maxfeatures] || WFS_FEATURE_LIMIT).to_i
      @srid = params['SRS'].split(/:/)[1].to_i rescue WGS84
      req_bbox = params['BBOX'].split(/,/).collect {|n| n.to_f } rescue nil
      @bbox = req_bbox || [-180.0, -90.0, 180.0, 90.0]
    end

    WFS_XML_ERB = <<EOS # :nodoc:
<?xml version='1.0' encoding="UTF-8" ?>
<wfs:FeatureCollection
   xmlns:ms="http://mapserver.gis.umn.edu/mapserver"
   xmlns:wfs="http://www.opengis.net/wfs"
   xmlns:gml="http://www.opengis.net/gml"
   xmlns:ogc="http://www.opengis.net/ogc"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://www.opengis.net/wfs http://schemas.opengeospatial.net/wfs/1.0.0/WFS-basic.xsd 
                       http://mapserver.gis.umn.edu/mapserver http://www.geopole.org/map/wfs?SERVICE=WFS&amp;VERSION=1.0.0&amp;REQUEST=DescribeFeatureType&amp;TYPENAME=geopole&amp;OUTPUTFORMAT=XMLSCHEMA">
  <gml:boundedBy>
    <gml:Box srsName="EPSG:<%= @srid %>">
      <gml:coordinates><%= @bbox[0] %>,<%= @bbox[1] %> <%= @bbox[2] %>,<%= @bbox[3] %></gml:coordinates>
    </gml:Box>
  </gml:boundedBy>
  <% for feature in @features -%>
    <gml:featureMember>
      <ms:geopole>
        <gml:boundedBy>
          <gml:Box srsName="EPSG:<%= @srid %>">
            <gml:coordinates><%= feature.x %>,<%= feature.y %> <%= feature.x %>,<%= feature.y %></gml:coordinates>
          </gml:Box>
        </gml:boundedBy>
        <ms:msGeometry>
        <gml:Point srsName="EPSG:<%= @srid %>">
          <gml:coordinates><%= feature.x %>,<%= feature.y %></gml:coordinates>
        </gml:Point>
        </ms:msGeometry>
        <ms:text><%= feature.text %></ms:text>
      </ms:geopole>
    </gml:featureMember>
  <% end -%>
</wfs:FeatureCollection>
EOS

    WFS_EMPTY_RESPONSE = <<EOS # :nodoc:
<?xml version='1.0' encoding="UTF-8" ?>
<wfs:FeatureCollection
   xmlns:wfs="http://www.opengis.net/wfs"
   xmlns:gml="http://www.opengis.net/gml"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://www.opengis.net/wfs http://schemas.opengeospatial.net/wfs/1.0.0/WFS-basic.xsd">
   <gml:boundedBy>
      <gml:null>missing</gml:null>
   </gml:boundedBy>
</wfs:FeatureCollection>
EOS
    
  end

end
