require File.dirname(__FILE__)+'/../js_host'
require 'spec'
require 'rack/test'

Sinatra::Base.set :environment, :test

include Rack::Test::Methods