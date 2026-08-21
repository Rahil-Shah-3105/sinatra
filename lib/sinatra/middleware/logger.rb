# frozen_string_literal: true

require 'logger'

module Sinatra
  module Middleware
    class Logger
      def initialize(app, level = ::Logger::INFO)
		warn("[DEBUG] >>> Entering initialize(app=#{app},level=#{level})")
		warn("[DEBUG] <<< Exiting initialize(app=#{app},level=#{level})")
        @app, @level = app, level
      end

      def call(env)
		warn("[DEBUG] >>> Entering call(env=#{env})")
        logger = ::Logger.new(env[Rack::RACK_ERRORS])
        logger.level = @level
		warn("[DEBUG] call(env=#{env}): logger.level → #{logger.level}")
		warn("[DEBUG] call(env=#{env}): logger → #{logger}")

        env[Rack::RACK_LOGGER] = logger
        @app.call(env)
      end
    end
  end
end
