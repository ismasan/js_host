require 'json'
require 'signature'

module JsHost
  
  # API for command line tool
  # Create accounts, push files
  class Api < Base
    
    class MissingParameters < RuntimeError; end

    helpers do
      include Helpers::Api
    end
    
    error Signature::AuthenticationError do |controller|
      error = controller.env["sinatra.error"]
      halt 401, "401 UNAUTHORIZED: #{error.message}\n"
    end
    
    error MissingParameters do |controller|
      halt 500, controller.env["sinatra.error"].message
    end

    get '/?' do
      'Jem API'
    end

    # Not authenticated
    put '/accounts' do
      raise MissingParameters, "missing email" unless params[:email]
      raise MissingParameters, "missing password" unless params[:password]

      # Create account
      account = Account.create(params)
      token = account.tokens.first
      
      content_type 'application/json'

      return JSON.generate({
        :id => account.id,
        :key => token.key,
        :secret => token.secret
      })
    end

    # Authenticated
    get '/account/:id' do
      account = authenticate!

      JSON.generate({
        :id => account.id,
        :key => account.key,
        :secret => account.secret
      })
    end

    post '/projects' do
      account = authenticate!

      return "Not done yet"
    end
  end
  
end