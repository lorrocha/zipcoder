class Zipcoder::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/setup.rake'
  end
end
