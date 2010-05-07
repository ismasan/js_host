module JsHost
  
  class AssetHost < Base
    
    configure :production do
      disable :raise_errors # so error handlers work
    end
    
    helpers do
      include Helpers::Base
      include Helpers::AssetHost
    end
    
    before do
      # Authorize
      # Set caching headers
      cache_long 5.minutes
      content_type 'text/javascript'
    end
    
    not_found do
      'File not found'
    end
    
    RESPOND_MINIFIED = proc do
      version_headers current_version
      minify current_version.hosted_file.body
    end
    
    RESPOND_RAW = proc do
      version_headers current_version
      current_version.hosted_file.body
    end
    
    # All projects for now
    get '/?' do
      content_type 'text/html'
      page_title 'All projects'
      @projects = Project.desc.includes(:account)
      erb :"projects/index"
    end
    
    # Project info, manifest, version list
    get '/:project_id?' do
      content_type 'text/html'
      page_title current_project.name
      erb :"projects/show"
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