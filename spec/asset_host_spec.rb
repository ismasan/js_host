require File.dirname(__FILE__) + '/spec_helper'

def app
  JsHost::AssetHost
end

describe 'foo' do
  it {'foo'.should == 'foo'}
end