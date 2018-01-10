require 'pry'
require 'zipcoder'

namespace :setup do
  desc 'Task to fetch zipcodes from its source and save it as a csv'
  task :load_zipcodes do
    binding.pry
  end
end
