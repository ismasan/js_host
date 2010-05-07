module JsHost
  
  # API for command line tool
  # Create accounts, push files
  class Api < Base
    
    helpers do
      include Helpers::Api
    end
    
    get '/?' do
      'API root'
    end
  end
  
end