require "zipcoder/version"
require "zipcoder/zipcode_downloader"
require "zipcoder/railtie" if defined?(Rails)
require 'pry'
require 'open-uri'
require 'zip'
require 'csv'

module Zipcoder
  class << self
     def start
       binding.pry
     end
   end
end
