require 'pry'

module Zipcoder
  class ZipcodeDownloader
    def self.download
      zipfile = Zipcoder::ZipfileHandler.get_zip_from_path(Zipcoder::ZIPCODE_DOWNLOAD_URI)
      new(zipfile).write_to_csv(Zipcoder::CSV_PATH)
    end

    def initialize(zipfile)
      @zipfile = zipfile
    end

    def write_to_csv(csv_path, headers=false)
      CSV.open(csv_path, "wb") do |csv|
        csv << Zipcoder::HEADERS_MAPPING.keys if headers
        @zipfile.read_content_from_zipfile("US.txt").each do |tsv_arr|
          csv << Zipcoder::HEADERS_MAPPING.map { |_, index| tsv_arr[index] }
        end
      end
    end
  end
end
