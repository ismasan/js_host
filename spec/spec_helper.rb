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

def signature_querystring(verb, path, key, secret)
  token = Signature::Token.new(key, secret)
  request = Signature::Request.new(verb, path, {})
  auth_hash = request.sign(token)

  auth_hash.keys.inject([]) do |array, key|
    array << "#{URI.encode(key.to_s)}=#{URI.encode(auth_hash[key].to_s)}"
  end.join('&')
end

def clear_database!
  JsHost::Models::Account.delete_all
  JsHost::Models::Project.delete_all
  JsHost::Models::Version.delete_all
  JsHost::Models::HostedFile.delete_all
end