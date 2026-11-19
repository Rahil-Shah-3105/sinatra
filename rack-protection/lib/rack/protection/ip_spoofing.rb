# frozen_string_literal: true

require 'rack/protection'

module Rack
l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
  module Protection
    ##
    # Prevented attack::   IP spoofing
    # Supported browsers:: all
    # More infos::         http://blog.c22.cc/2011/04/22/surveymonkey-ip-spoofing/
    #
    # Detect (some) IP spoofing attacks.
    class IPSpoofing < Base
      default_reaction :deny

      def accepts?(env)
		warn("[ERROR] >>> Entering accepts?(env=#{env})")
        return true unless env.include? 'HTTP_X_FORWARDED_FOR'

        ips = env['HTTP_X_FORWARDED_FOR'].split(',').map(&:strip)
        return false if env.include?('HTTP_CLIENT_IP') && (!ips.include? env['HTTP_CLIENT_IP'])
		warn("[DEBUG] accepts?(env=#{env}): ips → #{ips}")
		warn("[WARN] <<< Exiting accepts?(env=#{env})")
        return false if env.include?('HTTP_X_REAL_IP') && (!ips.include? env['HTTP_X_REAL_IP'])

        true
      end
    end
  end
end
