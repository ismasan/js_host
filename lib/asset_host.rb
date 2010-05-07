module JsHost
  
  class AssetHost < Base

    helpers do
      include Helpers::AssetHost
    end
    
    before do
      # Authorize
      # Set caching headers
      cache_long 5.minutes
      content_type 'text/javascript'
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