require 'models'
module JsHost
  module Helpers
    
    include JsHost::Models
    
    module Base
      def logger
        JsHost::LOGGER
      end
      
      def page_title(title = nil)
        @page_title = title if title
        @page_title.to_s
      end
      
      def cache_long(seconds = 3600)
        response['Cache-Control'] = "public, max-age=#{seconds.to_i}"
      end
    end
    
    module AssetHost
      def current_project
        @current_project ||= Models::Project.find_by_slug!(params[:project_id])
      end
      
      def current_version
        @current_version ||= current_project.versions.resolve_latest!(params[:major], params[:minor], params[:patch])
      end
      
      def minify(body)
        Closure::Compiler.new.compile body
      end
      
      def version_headers(version)
        etag version.etag
        response['X-Version'] = version.version_string
      end
      
      def version_path(version, minified = true, points = 3)
        m = minified ? '.min' : ''
        v = [version.major, version.minor, version.patch][0...points].join('.')
        "/#{version.project.to_param}/#{v}/#{version.hosted_file.to_param}#{m}.js"
      end
      
      def project_path(project)
        "/#{project.to_param}"
      end
      
    end
    
    module Api
      include JsHost::Models
      
      def hash_query_string
        request.query_string.split('&').inject({}) do |mem,e|
          s = e.split('=')
          mem[s.first] = s.last
          mem
        end
      end
      
      def authenticate!
        request = Signature::Request.new(env['REQUEST_METHOD'], env["PATH_INFO"], hash_query_string)
        token = request.authenticate do |key|
          Token.find_by_key!(key)
        end
        token.account
      end
    end
    
  end
  
end