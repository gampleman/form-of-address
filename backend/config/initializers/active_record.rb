require "yaml"
require "active_record"

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(YAML::load(File.open(File.expand_path('../../database.yml', __FILE__)))[ENV['RACK_ENV']])
