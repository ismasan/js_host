require File.dirname(__FILE__) + '/spec_helper'

def app
  JsHost::Api
end

describe JsHost::Api do
  
  before :each do
    clear_database!
    # logger = Logger.new("#{File.dirname(__FILE__)}/../log/test.log")
    # 
    #     JsHost::Base.use Rack::CommonLogger, logger
  end
  
  describe 'PUT /api/accounts' do
    
    describe 'with missing parameters' do
      it 'should respond with 400 Bad Request' do
        put '/accounts'
        last_response.status.should == 400
      end
    end
    
    describe 'with missing email' do
      it 'should respond with 400 Bad Request' do
        put '/accounts', :password => 'xxx'
        last_response.status.should == 400
      end
    end
    
    describe 'with missing password' do
      it 'should respond with 400 Bad Request' do
        put '/accounts', :email => 'demo@email.com'
        last_response.status.should == 400
      end
    end
    
    describe 'with invalid email' do
      it 'should respond with 400 Bad Request' do
        put '/accounts', :email => 'xxx', :password => 'xxx'
        last_response.status.should == 400
      end
    end
    
    describe 'with valid parameters' do
      
      before do
        put '/accounts', :email => 'test@email.com', :password => 'xxx'
        @account = Account.last
      end
      
      it 'should respond with 201 created' do
        last_response.status.should == 201
      end
      
      it 'should respond with JSON for new account with id, key and secret' do
        last_response.headers['Content-Type'].should == 'application/json'
        body = JSON.parse(last_response.body)
        body['id'].should == @account.id
        body['key'].should == @account.key
        body['secret'].should == @account.secret
      end
    end
    
  end
  
  describe 'GET /api/accounts/:id' do
    
    def dispatch_get(account, do_auth = true)
      path = "/accounts/#{account.id}"
      auth = do_auth ? signature_querystring('GET', path, account.key, account.secret) : ''
      get "#{path}?#{auth}"
    end
    
    before do
      put '/accounts', :email => 'test@email.com', :password => 'xxx'
      @account = Account.last
    end
    
    describe 'with missing auth' do
      before do
        dispatch_get @account, false
      end
      
      it 'should respond with 401 unauthorized' do
        last_response.status.should == 401
      end
    end
    
    describe 'with incorrect auth' do
      before do
        @account.stub!(:secret).and_return 'xxx'
        dispatch_get @account
      end
      
      it 'should respond with 401 unauthorized' do
        last_response.status.should == 401
      end
    end
    
    describe 'with correct auth' do
      before do
        dispatch_get @account
      end
      
      it 'should respond with 200 Ok' do
        last_response.status.should == 200
      end
      
      it 'should respond with JSON for new account with id, key and secret' do
        last_response.headers['Content-Type'].should == 'application/json'
        body = JSON.parse(last_response.body)
        body['id'].should == @account.id
        body['key'].should == @account.key
        body['secret'].should == @account.secret
      end
    end
    
  end
  
  describe 'PUT /projects' do
    
    def dispatch_project(account, params = {})
      path = '/projects'
      auth = signature_querystring('PUT', path, account.key, account.secret)
      put "#{path}?#{auth}", params
    end
    
    def put_version(account, version)
      @manifest = JSON.generate(:project => 'Demo', :version => version, :file => 'demo.js')
      @file = %(var foo = function(a){return a*2})
      dispatch_project account, :manifest => @manifest, :file => @file
    end
    
    before do
      put '/accounts', :email => 'test@email.com', :password => 'xxx'
      @account = Account.last
    end
    
    describe 'with incorrect auth' do
      before do
        @account.stub!(:secret).and_return 'xxx'
        put_version @account, '1.1.1'
      end
      
      it 'should respond with 401 unauthorized' do
        last_response.status.should == 401
      end
    end
    
    describe 'with correct auth and missing parameters' do
      before do
        dispatch_project @account
      end
      
      it 'should respond with 400 bad request' do
        last_response.status.should == 400
      end
    end
    
    describe 'with correct auth and correct parameters' do
      
      before do
        put_version @account, '1.1.1'
      end
      
      describe 'new project' do
        it 'should respond with 201 created' do
          last_response.status.should == 201
        end
        
        it 'should create a project' do
          Project.last.name.should == 'Demo'
          Project.last.latest_version.version_string.should == '1.1.1'
        end
      end
      
      describe 'putting to existing version' do
        
        before do
          put_version @account, '1.1.1'
        end
        
        it 'should respond with 409 conflict' do
          last_response.status.should == 409
        end
        
      end
      
      describe 'putting new version' do
        
        before do
          put_version @account, '1.1.2'
        end
        
        it 'should respond with 201 created' do
          last_response.status.should == 201
        end
        
        it 'should have created new version' do
          Project.last.name.should == 'Demo'
          Project.last.latest_version.version_string.should == '1.1.2'
        end
        
      end
      
    end
    
  end
end