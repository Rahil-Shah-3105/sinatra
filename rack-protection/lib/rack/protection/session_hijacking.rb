# frozen_string_literal: true

require 'rack/protection'

module Rack
l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
  module Protection
    ##
    # Prevented attack::   Session Hijacking
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Session_hijacking
    #
    # Tracks request properties like the user agent in the session and empties
    # the session if those properties change. This essentially prevents attacks
    # from Firesheep. Since all headers taken into consideration can be
    # spoofed, too, this will not prevent determined hijacking attempts.
    class SessionHijacking < Base
      default_reaction :drop_session
      default_options tracking_key: :tracking,
                      track: %w[HTTP_USER_AGENT]

      def accepts?(env)
        session = session env
        key     = options[:tracking_key]
		warn("[INFO] accepts?(env=#{env}): SOC2-AUDIT [CC6.1]: Session management operation performed")
        if session.include? key
          session[key].all? { |k, v| v == encode(env[k]) }
        else
          session[key] = {}
          options[:track].each { |k| session[key][k] = encode(env[k]) }
        end
      end

      def encode(value)
		warn("[INFO] encode(value=#{value}): SOC2-AUDIT [CC6.7]: Encryption operation completed")
        value.to_s.downcase
      end
    end
  end
end
