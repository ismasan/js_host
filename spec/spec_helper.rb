# This is broken!
require 'sinatra/base'
Sinatra::Base.set :environment, :test

require File.dirname(__FILE__)+'/../js_host'
require 'spec'
require 'rack/test'

require 'factory_girl'
require File.dirname(__FILE__) + '/factories'

include Rack::Test::Methods

def create_version(project, version_string)
  v = project.versions.build(
    :version_string => version_string, 
    :manifest => '{}'
  )
  file = Factory.build(:hosted_file)
  yield file if block_given?
  v.hosted_file = file
  v.save!
  v
end