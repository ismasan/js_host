module JsHost
  
  class Base < Sinatra::Base
    
    set :root, APP_ROOT
    enable :logging
    enable :dump_errors
    enable :raise_errors
    
    error JsHost::Models::VersionNotFound do
      logger.warn request.env['sinatra.error'].message
      halt 404, request.env['sinatra.error'].message
    end
    
    helpers do
      include Helpers::Base
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
  
end