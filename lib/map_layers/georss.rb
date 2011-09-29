module MapLayers

  # GeoRSS Server methods
  # http://www.georss.org/1
  module GeoRSS
    
    # Publish layer in GeoRSS format
    def georss
      rows = map_layers_config.model.find(:all, :limit => GEORSS_FEATURE_LIMIT)
      @features = rows.collect do |row|
        if map_layers_config.geometry
          Feature.from_geom(row.send(map_layers_config.text), row.send(map_layers_config.geometry), row.send(map_layers_config.id))
        else
          Feature.new(row.send(map_layers_config.text), row.send(map_layers_config.lon), row.send(map_layers_config.lat))
        end
      end
      @base_url = "http://#{request.env["HTTP_HOST"]}/"
      @item_url = "#{@base_url}#{map_layers_config.model_id.to_s.pluralize}"
      @title = map_layers_config.model_id.to_s.pluralize.humanize
      logger.info "MapLayers::GEORSS: returning #{@features.size} features"
      render :inline => GEORSS_XML_ERB, :content_type => "text/xml"
    rescue Exception => e
      logger.error "MapLayers::GEORSS: returning no features - Caught exception '#{e}'"
      render :text => GEORSS_EMPTY_RESPONSE, :content_type => "text/xml"
    end
    
    protected

    GEORSS_FEATURE_LIMIT = 1000
    
    GEORSS_XML_ERB = <<EOS # :nodoc:
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns="http://purl.org/rss/1.0/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:georss="http://www.georss.org/georss">
<docs>This is an RSS file.  Copy the URL into your aggregator of choice.  If you don't know what this means and want to learn more, please see: <span>http://platial.typepad.com/news/2006/04/really_simple_t.html</span> for more info.</docs>
<channel rdf:about="<%= @base_url %>">
<link><%= @base_url %></link>
<title><%= @title %></title>
<description></description>
<items>
<rdf:Seq>
<% for feature in @features -%>
<rdf:li resource="<%= @item_url %>/<%= feature.id %>"/>
<% end -%>
</rdf:Seq>
</items>
</channel>
<% ts=Time.now.rfc2822 -%>
<% for feature in @features -%>
<item rdf:about="<%= @item_url %>/<%= feature.id %>">
<!--<link><%= @item_url %>/<%= feature.id %></link>-->
<title><%= @title %></title>
<description><![CDATA[<%= feature.text %>]]></description>
<georss:point><%= feature.y %> <%= feature.x %></georss:point>
<dc:creator>map-layers</dc:creator>
<dc:date><%= ts %></dc:date>
</item>
<% end -%>
</rdf:RDF>
EOS


    GEORSS_EMPTY_RESPONSE = <<EOS # :nodoc:
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns="http://purl.org/rss/1.0/">
<docs></docs>
<channel rdf:about="http://purl.org/rss/1.0/">
<link>http://purl.org/rss/1.0/</link>
<title>Empty GeoRSS</title>
<description></description>
<items>
<rdf:Seq>
</rdf:Seq>
</items>
</channel>
</rdf:RDF>
EOS
    
  end
  
  # Remote http Proxy
  module Proxy
    
    # Register an url, before the proxy is called
    def register_remote_url(url)
      session[:proxy_url] ||= []
      session[:proxy_url] << url      
    end
    
    # Proxy for accessing remote files like GeoRSS, which is not allowed directly from the browser
    def proxy
      if session[:proxy_url].nil? || !session[:proxy_url].include?(params["url"])
        logger.warn "Proxy request not in session: #{params["url"]}"
        render :nothing => true
        return
      end
      
      url = URI.parse(URI.encode(params[:url]))
      logger.debug "Proxy request for #{url.scheme}://#{url.host}#{url.path}"
      
      result = Net::HTTP.get_response(url)
      render :text => result.body, :status => result.code, :content_type => "text/xml"
    end
  end

  # Restful feture Server methods (http://featureserver.org/)
  module Rest
    
    def index
      respond_to do |format|
        format.xml { wfs }
        format.kml { kml }
      end
    end
    
  end
end
