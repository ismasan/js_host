$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'sinatra/base'
require 'logger'
require 'active_record'
require 'closure-compiler'
require 'digest/sha1'

ActiveRecord::Base.establish_connection(
  YAML.load_file('./config/database.yml')[Sinatra::Base.environment.to_s]
)

module JsHost
  
  APP_ROOT = File.dirname(__FILE__)
  
  autoload :Helpers, 'helpers'
  autoload :Models, 'models'
  autoload :Base, 'base'
  autoload :AssetHost, 'asset_host'
  autoload :Api, 'api'
  
end