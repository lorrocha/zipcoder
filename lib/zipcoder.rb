require "zipcoder/version"
require "zipcoder/zipcode_downloader"
require "zipcoder/utilities/zipfile_handler"
require "zipcoder/railtie" if defined?(Rails)
require 'pry'
require 'open-uri'
require 'csv'

module Zipcoder
  class << self
     def start
       binding.pry
     end
   end
end
