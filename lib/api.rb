module JsHost
  
  # API for command line tool
  # Create accounts, push files
  class Api < Base
    
    VALID_EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    
    disable :show_exceptions
    disable :raise_errors
    
    class MissingParameters < RuntimeError; end
    class InvalidParameters < MissingParameters; end
    
    helpers do
      include Helpers::Base
      include Helpers::Api
    end
    
    error ActiveRecord::RecordNotFound do |controller|
      error = controller.env["sinatra.error"]
      halt 404, "404 NOT FOUND: #{error.message}\n"
    end
    
    error Signature::AuthenticationError do |controller|
      error = controller.env["sinatra.error"]
      halt 401, "401 UNAUTHORIZED: #{error.message}\n"
    end
    
    error MissingParameters do |controller|
      halt 400, controller.env["sinatra.error"].message
    end
    
    error InvalidParameters do |controller|
      halt 400, controller.env["sinatra.error"].message
    end
    
    error JsHost::Models::Account::VersionExists do |controller|
      halt 409, controller.env["sinatra.error"].message
    end

    get '/?' do
      'Jem API'
    end
    
    # Authenticated
    get '/accounts/:id' do
      account = authenticate!
      content_type 'application/json'
      JSON.generate({
        :id => account.id,
        :key => account.key,
        :secret => account.secret
      })
    end
    
    # Not authenticated
    put '/accounts' do
      raise MissingParameters, "missing email" unless params[:email]
      raise MissingParameters, "missing password" unless params[:password]
      raise InvalidParameters, "invalid email" unless params[:email] =~ VALID_EMAIL
      # Create account
      account = Account.create(params)
      
      content_type 'application/json'
      
      halt 201, JSON.generate({
        :id => account.id,
        :key => account.key,
        :secret => account.secret
      })
    end

    put '/projects' do
      raise MissingParameters , 'missing manifest' unless params[:manifest]
      raise MissingParameters , 'missing file' unless params[:file]

      account = authenticate!
      account.create_or_update_project!(params[:manifest], params[:file])
      halt 201, 'Version created'
    end
  end
  
end