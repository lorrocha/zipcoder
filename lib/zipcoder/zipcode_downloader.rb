module Zipcoder
  class ZipcodeDownloader
    # The URI for the download - if it changes, change it here
    ZIPCODE_DOWNLOAD_URI = 'http://download.geonames.org/export/zip/US.zip'

    def self.download
      zipfile = new(ZIPCODE_DOWNLOAD_URI, "US.txt")
      csv_path = Pathname.new( __dir__ + "/data/us_zipcodes.csv")
      zipfile.write_to_csv(csv_path)
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

    def initialize(zipcode_uri, filename)
      zipped_directory = grab_zipfile_from_uri(zipcode_uri)
      @tsv_content = read_content_from_zip_file(filename, zipped_directory)
    end

    def grab_zipfile_from_uri(zipcode_uri)
      open(zipcode_uri)
    end

    def write_to_csv(csv_path, headers=true)
      CSV.open(csv_path, "wb") do |csv|
        csv << headers_mapping.keys if headers
        @tsv_content.each do |tsv_arr|
          csv << headers_mapping.map { |_, index| tsv_arr[index] }
        end
      end

    end

    def read_content_from_zip_file(filename, zipped_directory)
      content = nil
      Zip::File.open(zipped_directory) { |zipfile|
        target_file = zipfile.detect { |zfile| zfile.name == filename }
        content = target_file.get_input_stream.read
      }
      content.split("\n").map { |l| l.split("\t") }
    end
  end
end
