# kml builder
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://earth.google.com/kml/2.0") do
  xml.Document do

    xml.folder do
      xml.name @folder_name
    end

    @features.each do |feature|
    # kml(plaque, xml)
      xml.placemark do
        #xml.name @folder_name
        xml.description do
          xml.cdata! feature.text
        end
        xml.point do
          xml.coordinates "#{feature.x}, #{feature.y}, 0"
        end
      end
    end

  end
end

