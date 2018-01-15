require "zipcoder/version"
require "zipcoder/zipcode_downloader"
require "zipcoder/utilities/zipfile_handler"
require "zipcoder/railtie" if defined?(Rails)
require "zipcoder/errors"
require 'pry'
require 'open-uri'
require 'csv'
require 'zip'


module Zipcoder
  # Path where the zipcode csv will be stored
  CSV_PATH = Pathname.new( File.dirname(__FILE__) + "/zipcoder/data/us_zipcodes.csv")

  # The URI for the download
  ZIPCODE_DOWNLOAD_URI = 'http://download.geonames.org/export/zip/US.zip'

  # Defines the mapping for converting the downloaded file into the params we want
  HEADERS_MAPPING = {
    # Header              -> Index from the download source
    "country_code"        => 0,
    "zipcode"             => 1,
    "city"                => 2,
    "state"               => 3,
    "state_abbreviation"  => 4,
    "latitide"            => 9,
    "longitude"           => 10
  }

  class << self
    def identify(value, options={})
      if value.class == Hash
        search_for(value, options)
      else
        search_for({zipcode: value}, options)
      end
    end

    def search_for(arguments, options={})
      # validate all argument columns
      arguments.keys.each do |column|
        validate_column column
      end

      # the first value of the first argument
      csv = find_all(arguments.first.last, options)
      conditions = build_conditions_from(arguments, options)

      # Only select the rows that satisfy all conditions
      rows = csv.select { |line| conditions.all? { |cond| cond.call(line) } }
      CSV::Table.new(rows)
    end

    def find_all(datum, options={})
      # We don't want to read the entire file into CSV because making a large CSV is slow
      # So only return possible lines that might match THEN return the CSV
      grep_value = (options[:case_insensitive] ? /#{datum}/i : /#{datum}/)
      lines_with_zipcode = IO.foreach(CSV_PATH).lazy.grep(grep_value).to_a.join

      CSV.parse(lines_with_zipcode, headers: HEADERS_MAPPING.keys).tap { |result|
        raise(Zipcoder::ResultsNotFound, "There is no data found for value: #{datum}") if result.length < 1
      }
    end

    private
    def validate_column(column)
      raise(Zipcoder::HeaderNotSupported, "The column `#{column}` is not supported. Please add it to the HEADERS_MAPPING if it is intended to be supported.") unless HEADERS_MAPPING.include?(column.to_s)
    end

    def build_conditions_from(arguments, options)
      # This returns a array of procs that need to be evaluated as true
      arguments.map { |column, value|
        if options[:case_insensitive]
          -> (line) { line[HEADERS_MAPPING[column.to_s]].downcase.include? value.downcase }
        else
          -> (line) { line[HEADERS_MAPPING[column.to_s]].include? value }
        end
      }
    end
  end
end
