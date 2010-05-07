require 'models'
module JsHost
  module Helpers
    
    include JsHost::Models
    
    module Base
      def logger
        LOGGER
      end
      
      def cache_long(seconds = 3600)
        response['Cache-Control'] = "public, max-age=#{seconds.to_i}"
      end
    end
    
    module AssetHost
      def current_project
        @current_project ||= Models::Project.find_by_slug(params[:project_id]) or halt(404, 'Not Found')
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
      
      def version_headers(version)
        response['X-Version'] = version.version_string
      end
      
    end
    
    module Api
      
    end
    
  end
  
end