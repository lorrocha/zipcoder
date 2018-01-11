module Zipcoder
  class ZipcodeDownloader
    # The URI for the download - if it changes, change it here
    ZIPCODE_DOWNLOAD_URI = 'http://download.geonames.org/export/zip/US.zip'

    def self.download
      zipfile = Zipcoder::ZipfileHandler.get_zip_from_path(ZIPCODE_DOWNLOAD_URI)
      csv_path = Pathname.new( __dir__ + "/data/us_zipcodes.csv")
      new(zipfile).write_to_csv(csv_path)
    end

    def initialize(zipfile)
      @zipfile = zipfile
    end

    def headers_mapping
      # Defines the mapping for converting the downloaded file into the params we want
      {
        # Header  -> Index
        "Country Code"        => 0,
        "Postal Code"         => 1,
        "City"                => 2,
        "State"               => 3,
        "State Abbreviation"  => 4,
        "Latitude"            => 9,
        "Longitude"           => 10
      }
    end

    def write_to_csv(csv_path, headers=true)
      CSV.open(csv_path, "wb") do |csv|
        csv << headers_mapping.keys if headers
        @zipfile.read_content_from_zipfile("US.txt").each do |tsv_arr|
          csv << headers_mapping.map { |_, index| tsv_arr[index] }
        end
      end
    end
  end
end
