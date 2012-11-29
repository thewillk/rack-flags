require_relative '../spec_helper'

require 'sinatra'
require 'rack/test'

class ReaderApp < Sinatra::Base
  enable :raise_errors
  disable :show_exceptions 

  get "/" do
    flags = TeeDub::FeatureFlags.for_env(env)

    output = []
    if flags.on?( :foo )
      output << "foo is on"
    else
      output << "foo is off"
    end

    if flags.on?( :bar )
      output << "bar is on"
    else
      output << "bar is off"
    end

    output.join("; ")
  end
end


describe 'reading feature flags in an app' do
  include Rack::Test::Methods

  let( :config_file ) { Tempfile.new('tee-dub-feature-flags acceptance test example config file') }
  let( :config_contents ){ "" }

  before :each do
    config_file.write( config_contents )
    config_file.flush
  end

  after :each do
    config_file.unlink
  end

  let( :app ) do
    yaml_path = config_file.path
    Rack::Builder.new do
      use TeeDubFeatureFlags::RackMiddleware, yaml_path: yaml_path
      run ReaderApp
    end
  end

  context 'no base flags, no overrides' do
    it 'should interpret both foo and bar as off by default' do
      get '/'
      last_response.body.should == 'foo is off; bar is off'
    end
  end

  context 'foo defined as a base flag, defaulted to true' do
    let( :config_contents ) do
      <<-EOS
      foo: 
        default: true
      EOS
    end

    xit 'should interpret foo as on and bar as off' do
      get '/'
      last_response.body.should == 'foo is on; bar is off'
    end

  end

end
