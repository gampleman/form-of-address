require 'bundler/setup'
require 'praxis'

ENV['RACK_ENV'] = 'test'

application = Praxis::Application.instance
application.logger = Logger.new(STDOUT)
application.setup

require_relative '../config/environment.rb'

Test::Unit::AutoRunner.need_auto_run = false if defined?(Test::Unit::AutoRunner)

RSpec.configure(&:raise_errors_for_deprecations!)

module ApiHelper
  include Rack::Test::Methods
  def app
    Praxis::Application.instance
  end

  def request
    last_request
  end

  def response
    last_response
  end

  def json_response
    content_type = last_response.headers['Content-Type']

    if content_type&.include?('json')
      begin
        JSON.parse(last_response.body)
      rescue
        nil
      end
    end
  end

  def controller
    request.env['app.controller']
  end

  def use_api_version(version)
    header 'X-Api-Version', version
    header 'Content-Type', 'application/json'
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :rack, file_path: /(spec\/controllers)/
end
