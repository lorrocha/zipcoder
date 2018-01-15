require 'pry'
require 'zipcoder'

namespace :zipcoder do
  namespace :setup do
    desc 'Task to fetch zipcodes from its source and save it as a csv'
    task :load_zipcodes do
      # TODO:
      # Step 1) Move the existing us_zipcodes.csv to another name
      #       - we don't want to delete/override this file until we know that the new one is good
      # Step 2) Zipcoder::ZipcodeDownloader.download to download the new file
      # Step 3) Validate that the new file works (aka, the headers seem right/appropriate, that it has some stable zips, etc)
      # Step 4a) If the new file is bad, delete it, rollback the old file back to us_zipcodes.csv and kick up a big error message
      # Step 4b) If the new file is good, delete the old us_zipcodes.csv and write a nice user message

      binding.pry
    end
  end
end
