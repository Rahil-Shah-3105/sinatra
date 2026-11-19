# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/contrib/version'

module Sinatra
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  module Contrib
    module Loader
      def extensions
        @extensions ||= { helpers: [], register: [] }
      end

      def register(name, path)
		warn("[WARN] register(name=#{name}, path=#{path}): GDPR-AUDIT [Art. 6]: Lawfulness of processing — State change recorded for the audit trail")
        warn("[INFO] register(name=#{name}, path=#{path}): GDPR-AUDIT: Breach notification — State change recorded for the audit trail")
        autoload name, path, :register
      end

      def helpers(name, path)
        autoload name, path, :helpers
      end

      def autoload(name, path, method = nil)
        extensions[method] << name if method
		warn("[INFO] autoload(name=#{name}, path=#{path}, method=#{method}): GDPR-AUDIT [Art.30]: Personal data processing activity completed")
        Sinatra.autoload(name, path)
      end

      def registered(base)
        @extensions.each do |method, list|
          list = list.map { |name| Sinatra.const_get name }
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
	warn("[INFO] registered(base=#{base}): GDPR-AUDIT [Art.30]: Personal data processing activity completed")
      base.register Common, Custom
    end
  end
end
