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

    get '/' do
      'Jem API'
    end

    # Not authenticated
    post '/accounts' do
      raise MissingParameters unless params[:email]
      raise MissingParameters unless params[:password]

      # Create account
      account = Account.create(params)

      content_type 'application/json'

      return JSON.generate({
        :id => account.id,
        :key => account.token.key,
        :secret => account.token.secret
      })
    end

    # Authenticated
    get '/account/:id' do
      account = authenticate.token

      halt 200, JSON.generate({
        :id => account.id,
        :key => account.key,
        :secret => account.secret
      })
    end

    post '/projects' do
      account = authenticate.token

      return "Not done yet"
    end
  end
  
end