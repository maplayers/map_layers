# kml builder
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://earth.google.com/kml/2.0") do
  xml.Document do

    xml.folder do
      xml.name @folder_name
    end

    @features.each do |feature|
      unless feature.latitude.nil? || feature.longitude.nil?
        xml.placemark do
          # place name
          name = feature.respond_to?('name') ? feature.name : "#{dom_id(feature)}"
          xml.name "#{name}"

          # place description
          xml.description do
            xml.cdata! "#{feature.description}"
          end

          # place geoloc
          altitude = feature.respond_to?('altitude') ? feature.altitude : 0
          xml.point do
            xml.coordinates "#{feature.latitude}, #{feature.longitude}, #{altitude}"
          end
        end
      end
    end

  end
end
