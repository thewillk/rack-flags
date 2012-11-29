require 'tee-dub-feature-flags/version'
require 'tee-dub-feature-flags/defaults'
require 'tee-dub-feature-flags/flag_overrides'
require 'tee-dub-feature-flags/derived_flags'

require 'tee-dub-feature-flags/config'
require 'tee-dub-feature-flags/reader'

require 'tee-dub-feature-flags/rack_middleware'
require 'tee-dub-feature-flags/admin_app'

module TeeDub
  module FeatureFlags
    def self.for_env(env)
      base_flags = []
      overrides = {}
      Reader.new( base_flags, overrides )
    end
  end
end