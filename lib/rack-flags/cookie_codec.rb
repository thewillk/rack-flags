module RackFlags

  class CookieCodec
    COOKIE_KEY='rack-flags'

    class Parser
      attr_reader :overrides

      def self.parse(cookie_value)
        parser = new 
        parser.parse(cookie_value)
        parser.overrides
      end

      def initialize()
        @overrides = {}
      end

      def parse(raw_overrides)
        return if raw_overrides.nil?

        raw_overrides.split(' ').each do |override|
          parse_override(override)
        end
      end

      private

      BANG_DETECTOR = Regexp.compile(/^!(.+)/)

      def parse_override(override)
        if override_without_bang = override[BANG_DETECTOR,1]
          add_override(override_without_bang,false)
        else
          add_override(override,true)
        end
      end

      def add_override( name, value )
        @overrides[name.to_sym] = value
      end
    end

    def overrides_from_env(env)
      req = Rack::Request.new(env)
      raw_overrides = req.cookies[COOKIE_KEY]
      Parser.parse( raw_overrides )
    end

    def generate_cookie_from(overrides)
      cookie_values = overrides.map {|flag_name, flag_value| cookie_value_for(flag_name, flag_value) }
      cookie_values.compact.join(' ')
    end

    private

      def cookie_value_for(flag_name, flag_value)
        case flag_value
        when true then flag_name
        when false then "!#{flag_name}"
        else nil
        end
      end
  end

end
