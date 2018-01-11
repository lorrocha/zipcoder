require 'zip'
require 'open-uri'

module Zipcoder
  class ZipfileHandler
    def self.get_zip_from_uri(path)
      zipped_directory = open(path)
      new(zipped_directory)
    end

    attr_reader :zipped_directory

    def initialize(zipped_directory)
      @zipped_directory = zipped_directory
    end

    def read_content_from_zipfile(filename)
      content = nil
      Zip::File.open(zipped_directory) { |zipfile|
        target_file = zipfile.detect { |zfile| zfile.name == filename }
        content = target_file.get_input_stream.read
      }
      format_string content
    end

    private

    def format_string(content)
      content.split("\n").map { |l| l.split("\t") }
    end
  end
end
