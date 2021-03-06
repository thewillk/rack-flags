require_relative '../spec_helper'
require 'rack/test'
require 'capybara/rspec'

module ConfigFileHelper

  def ff_config_file_path
    ff_yaml_file.path
  end

  def ff_config_file_contains(config)
    ff_yaml_file.write( config.to_yaml )
    ff_yaml_file.flush
  end

  def teardown_ff_config_file_if_exists
    @_ff_yaml_file.unlink if @_ff_yaml_file
  end

  def ff_yaml_file
    @_ff_yaml_file ||= Tempfile.new('rack-flags acceptance test example config file')
  end
end

module CookieHelper
  def set_feature_flags_cookie ff_cookie
    raw_cookie = "#{RackFlags::CookieCodec::COOKIE_KEY}=#{Rack::Utils.escape(ff_cookie)}"
    set_cookie(raw_cookie)
  end
end

RSpec.configure do |config|
  include ConfigFileHelper
  include CookieHelper

  config.after :each do
    teardown_ff_config_file_if_exists
  end
end
