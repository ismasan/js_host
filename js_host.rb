require 'sinatra/base'
require 'logger'
require 'active_record'
require 'closure-compiler'

ActiveRecord::Base.establish_connection(
  YAML.load_file('./config/database.yml')[Sinatra::Base.environment.to_s]
)

module JsHost
  
  class VersionNotFound < StandardError
    def initialize(conditions)
      @conditions = conditions
      super
    end
    
    def message
      "No file hosted with version #{@conditions.inspect}"
    end
  end
  
  module Models
    
    class Project < ActiveRecord::Base
      # belongs_to :account
      has_many :hosted_files, :dependent => :destroy
    end
    
    class HostedFile < ActiveRecord::Base
      belongs_to :project
      has_many :versions, :dependent => :destroy
      
      # name, url, etc
    end
    
    class Version < ActiveRecord::Base
      
      belongs_to :hosted_file
      
      scope :sorted_by_version, order("major DESC, minor DESC, patch DESC")
      
      def version_string
        [major, minor, patch].join('.')
      end
      
      def self.resolve_latest(major, minor = nil, patch = nil)
        r = where(:major => major)
        r = r.where(:minor => minor) if minor
        r = r.where(:patch => patch) if patch
        
        r.sorted_by_version.first or raise JsHost::VersionNotFound.new({:major => major, :minor => minor, :patch => patch})
      end
      
    end
    
  end
  
  class Base < Sinatra::Base
    
    set :root, File.dirname(__FILE__)
    enable :logging
    enable :dump_errors
    enable :raise_errors
    
    include JsHost::Models
    
    error JsHost::VersionNotFound do
      logger.warn request.env['sinatra.error'].message
      halt 404, request.env['sinatra.error'].message
    end
    
    helpers do
      
      def current_project
        @current_project ||= Project.find_by_slug(params[:project_id]) or halt(404, 'Not Found')
      end
      
      def current_file
        @current_file ||= current_project.hosted_files.find_by_slug(params[:file]) or halt(404, 'Not Found')
      end
      
      def current_version
        @current_version ||= current_file.versions.resolve_latest(params[:major], params[:minor], params[:patch])
      end
      
      def minify(body)
        Closure::Compiler.new.compile body
      end
      
      def logger
        LOGGER
      end
      
      def cache_long(seconds = 3600)
        response['Cache-Control'] = "public, max-age=#{seconds.to_i}"
      end
      
    end
    
    configure do
      LOGGER = Logger.new(STDOUT)
      LOGGER.level = Logger::DEBUG
      ActiveRecord::Base.logger = LOGGER
      ActiveRecord::Base.establish_connection(
        YAML.load_file(root + '/config/database.yml')[Sinatra::Base.environment.to_s]
      )
    end
    
  end
  
  # Accounts API. Create and edit accounts. Versioned.
  class AccountsApi < Base
    get '/?' do
      'Accounts API root'
    end
  end
  
  # Uploads API. CRUD projects and push versions. Versioned.
  class ProjectsApi < Base
    
    get '/?' do
      'Projects API root'
    end
  end
  
  class AssetHost < Base

    before do
      # Authorize
      # Set caching headers
      cache_long 5.minutes
      content_type 'text/javascript'
    end
    
    helpers do
      def version_headers(version)
        response['X-Version'] = version.version_string
      end
    end
    
    RESPOND_MINIFIED = proc do
      version_headers current_version
      minify current_version.body
    end
    
    RESPOND_RAW = proc do
      version_headers current_version
      current_version.body
    end
    
    get '/' do
      'Hello'
    end
    
    # major, minor, patch ::::::::::::::::::::::::::
    get '/:project_id/:major.:minor.:patch/:file.min.js', &RESPOND_MINIFIED
    
    get '/:project_id/:major.:minor.:patch/:file.js', &RESPOND_RAW
    
    
    # major, minor ::::::::::::::::::::::::::::::::
    get '/:project_id/:major.:minor/:file.min.js', &RESPOND_MINIFIED
    
    get '/:project_id/:major.:minor/:file.js', &RESPOND_RAW
    
    # major :::::::::::::::::::::::::::::::::::::::
    get '/:project_id/:major/:file.min.js', &RESPOND_MINIFIED
    
    get '/:project_id/:major/:file.js', &RESPOND_RAW
    
  end
end