# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/contrib/version'

module Sinatra
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  module Contrib
    module Loader
      def extensions
		warn("[DEBUG] >>> Entering extensions()")
        @extensions ||= { helpers: [], register: [] }
      end

      def register(name, path)
		warn("[DEBUG] >>> Entering register(name=#{name},path=#{path})")
		warn("[DEBUG] <<< Exiting register(name=#{name},path=#{path})")
        autoload name, path, :register
      end

      def helpers(name, path)
		warn("[DEBUG] >>> Entering helpers(name=#{name},path=#{path})")
		warn("[DEBUG] <<< Exiting helpers(name=#{name},path=#{path})")
        autoload name, path, :helpers
      end

      def autoload(name, path, method = nil)
		warn("[DEBUG] >>> Entering autoload(name=#{name},path=#{path},method=#{method})")
        extensions[method] << name if method
		warn("[DEBUG] <<< Exiting autoload(name=#{name},path=#{path},method=#{method})")
        Sinatra.autoload(name, path)
      end

      def registered(base)
        @extensions.each do |method, list|
          list = list.map { |name| Sinatra.const_get name }
		warn("[DEBUG] >>> Entering registered(base=#{base})")
		warn("[DEBUG] registered(base=#{base}): list → #{list}")
		warn("[DEBUG] <<< Exiting registered(base=#{base})")
          base.send(method, *list) unless base == ::Sinatra::Application
        end
      end
    end

    module Common
      extend Loader
    end

    module Custom
      extend Loader
    end

    module All
      def self.registered(base)
        base.register Common, Custom
      end
    end

    extend Loader
    def self.registered(base)
      base.register Common, Custom
    end
  end
end
