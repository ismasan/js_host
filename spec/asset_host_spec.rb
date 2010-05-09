require File.dirname(__FILE__) + '/spec_helper'

def app
  JsHost::AssetHost
end

def version_path(version, version_string, min = false)
  m = min ? '.min' : ''
  "/#{version.project.to_param}/#{version_string}/#{version.hosted_file.to_param}#{m}.js"
end

describe JsHost::AssetHost do
  
  before do
    @account = Factory(:account)
    @project = Factory(:project, :name => 'demo', :account => @account)
    @v1_1_1 = create_version(@project, '1.1.1') do |f|
      %(
        // Comment 1.1.1
        
        function foo1_1_1(bar){
          return 2 * bar
        }
      )
    end
    
    @v1_1_2 = create_version(@project, '1.1.2') do |f|
      %(
        // Comment 1.1.2
        
        function foo1_1_2(bar){
          return 2 * bar
        }
      )
    end
    
    @v1_2_0 = create_version(@project, '1.2.0') do |f|
      %(
        // Comment 1.2.0
        
        function foo1_2_0(bar){
          return 2 * bar
        }
      )
    end
    
  end
  
  after do
    Account.destroy_all
  end
  
  describe 'routes' do
    describe '/:project_id/:major.:minor.:patch/:file.js' do
      
      describe 'when resource not found' do
        it 'should respond with status 404' do
          get version_path(@v1_1_1, '1.1.10')
          last_response.status.should == 404
        end
      end
      
      describe 'when resource found' do
        before { get version_path(@v1_1_1, '1.1.1') }

        it 'should respond with specific version' do
          last_response.body.should == @v1_1_1.hosted_file.body
        end

        it 'should set HTTP time-based caching headers' do
          last_response.headers['Cache-Control'].should == "public, max-age=300"
        end

        it 'should set HTTP etag caching headers' do
          last_response.headers['Etag'].gsub('"','').should == @v1_1_1.etag.to_s
        end
      end
      
    end

    describe '/:project_id/:major.:minor.:patch/:file.min.js' do
      it 'should respond with minified specific version' do
        get version_path(@v1_1_1, '1.1.1', true)
        last_response.body.should == "function foo1_1_1(a){return 2*a};\n"
      end
    end

    describe '/:project_id/:major.:minor/:file.js' do
      
      describe 'when resource not found' do
        it 'should respond with status 404' do
          get version_path(@v1_1_1, '1.10')
          last_response.status.should == 404
        end
      end
      
      describe 'when resource found' do
        before { get version_path(@v1_1_2, '1.1') }

        it 'should default to latest patch version' do
          last_response.body.should == @v1_1_2.hosted_file.body
        end

        it 'should set HTTP time-based caching headers' do
          last_response.headers['Cache-Control'].should == "public, max-age=300"
        end

        it 'should set HTTP etag caching headers' do
          last_response.headers['Etag'].gsub('"','').should == @v1_1_2.etag.to_s
        end
      end
      
    end

    describe '/:project_id/:major.:minor/:file.min.js' do
      it 'should default to minified latest patch version' do
        get version_path(@v1_1_2, '1.1', true)
        last_response.body.should == "function foo1_1_2(a){return 2*a};\n"
      end
    end

    describe '/:project_id/:major/:file.js' do
      it 'should default to latest minor and patch version'
      it 'should set HTTP time-based caching headers'
      it 'should set HTTP etag caching headers'      
    end

    describe '/:project_id/:major/:file.min.js' do
      it 'should default to minified latest minor and patch version'
      it 'should set HTTP time-based caching headers'
      it 'should set HTTP etag caching headers'      
    end
  end
  
end