module JsHost
  
  class Base < Sinatra::Base
    
    include JsHost::Models
    
    set :root, APP_ROOT
    set :views, APP_ROOT + '/views'
    set :public, APP_ROOT + '/public'
    enable :logging
    enable :dump_errors
    enable :raise_errors
    
    helpers do
      include Helpers::Base
    end
    
    configure do
      ActiveRecord::Base.establish_connection(
        YAML.load_file(root + '/config/database.yml')[Sinatra::Base.environment.to_s]
      )
    end
    
  end
  
end