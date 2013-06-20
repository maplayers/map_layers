# kml builder
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://earth.google.com/kml/2.2") do
  xml.Document do
    xml.name "#{@features.class.to_s}_collection"

    # styles examples
    xml.StyleMap :id => "sunny_icon_pair" do
      xml.Pair do
        xml.key "normal"
        xml.styleUrl "#sunny_icon_normal"
      end
      xml.Pair do
        xml.key "highlight"
        xml.styleUrl "#sunny_icon_highlight"
      end
    end

    xml.Style :id => "sunny_icon_normal" do
      xml.IconStyle do
        xml.scale "1.2"
        xml.Icon do
          xml.href "http://maps.google.com/mapfiles/kml/shapes/sunny.png"
        end
        xml.hotSpot :x => "0.5", :y => "0.5", :xunits => "fraction", :yunits => "fraction"
      end
      xml.LabelStyle do
        xml.color "ff00aaff"
      end
    end

    xml.Style :id => "sunny_icon_highlight" do
      xml.IconStyle do
        xml.scale "1.4"
        xml.Icon do
          xml.href "http://maps.google.com/mapfiles/kml/shapes/sunny.png"
        end
        xml.hotSpot :x => "0.5", :y => "0.5", :xunits => "fraction", :yunits => "fraction"
      end
      xml.LabelStyle do
        xml.color "ff00aaff"
      end
    end

    #xml.Style ... your styles here

    xml.Folder do
      xml.name @folder_name

      @features.each do |feature|
        unless feature.latitude.nil? || feature.longitude.nil?
          xml.Placemark do
            # id
            xml.id "#{dom_id(feature)}"

            # place name
            name = feature.respond_to?('name') ? feature.name : "#{dom_id(feature)}"
            xml.name "#{name}"

            # place description
            xml.description do
              xml.cdata! "#{feature.description}"
            end

            # popup url
            xml.popup_content_url polymorphic_path([:popup_content, feature]) rescue nil

            xml.styleUrl "#sunny_icon_pair"
            #xml.styleUrl "##{feature.map_layers_marker}" if feature.respond_to?('map_layers_marker')

            # place link
            #xml.link browse_path(feature.url)

            # place geoloc
            altitude = feature.respond_to?('altitude') ? feature.altitude : 0
            xml.Point do
              xml.coordinates "#{feature.longitude.to_f},#{feature.latitude.to_f},#{altitude}"
            end
          end
        end
      end

    end


  end
end

