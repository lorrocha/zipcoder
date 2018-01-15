require "zipcoder/version"
require "zipcoder/zipcode_downloader"
require "zipcoder/utilities/zipfile_handler"
require "zipcoder/railtie" if defined?(Rails)
require 'pry'
require 'open-uri'
require 'csv'
require 'zip'


module Zipcoder
  CSV_PATH = Pathname.new( File.dirname(__FILE__) + "/zipcoder/data/us_zipcodes.csv")
  # The URI for the download - if it changes, change it here
  ZIPCODE_DOWNLOAD_URI = 'http://download.geonames.org/export/zip/US.zip'

  # Defines the mapping for converting the downloaded file into the params we want
  HEADERS_MAPPING = {
    # Header              -> Index
    "Country Code"        => 0,
    "Postal Code"         => 1,
    "City"                => 2,
    "State"               => 3,
    "State Abbreviation"  => 4,
    "Latitude"            => 9,
    "Longitude"           => 10
  }

  class << self
     def info_for(zipcode)
       csv = read_csv(zipcode)
       csv.detect { |line| line[HEADERS_MAPPING["Postal Code"]] == zipcode }
     end

     private
     def read_csv(zipcode)
       # We don't want to read the entire file into CSV because making a large CSV is slow
       # So only return possible lines that might match THEN return the CSV
       lines_with_zipcode = IO.foreach(CSV_PATH).lazy.grep(/#{zipcode}/).to_a.join
       CSV.parse(lines_with_zipcode, headers: HEADERS_MAPPING.keys)
     end
   end
end
