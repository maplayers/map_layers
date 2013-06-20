# gpx builder
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8", :standalone => "no"
xml.gpx(:xmlns=>"http://www.topografix.com/GPX/1/1") do
# <gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" creator="Oregon 400t" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">
  xml.trk do
    xml.name "name"
    xml.trkseg do
      xml.trkpt :lat => '43.858259', :lon => '11.097178' do
        xml.ele '66.468262'
        xml.time '2005-03-20T07:20:37Z'
      end
      xml.trkpt :lat => '43.858259', :lon => '11.097178' do
        xml.ele '66.468262'
        xml.time '2005-03-20T07:20:37Z'
      end
    end
  end
end
