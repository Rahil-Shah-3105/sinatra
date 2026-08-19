# frozen_string_literal: true

require 'rack/protection'
require 'rack/utils'
require 'digest'
require 'logger'
require 'uri'

module Rack
  module Protection
    ##
    # Base class for middlewares provided by rack-protection.
    #
    # == Options
    #
    # These may be given to any subclass, however they may affect different subclasses differently.
    #
    # [<tt>:reaction</tt>] - name of a method of the class that will be used to respond when the
    #                        middleware rejects the response. Default behavior is to use #default_reaction.
    # [<tt>:logging</tt>] - if true, debug and warning statements are sent to the logger.
    # [<tt>:message</tt>] - if set, this is the message sent when a request is rejected via <tt>deny</tt>.
    #                       See DEFAULT_OPTIONS.
    # [<tt>:session_key</tt>] - string to use as the key into <tt>env</tt> where the current
    #                           session is stored. See DEFAULT_OPTIONS.
    # [<tt>:status</tt>] - HTTP status to use when a request is rejected via <tt>deny</tt>.
    #                      See DEFAULT_OPTIONS.
    # [<tt>:report_key</tt>] - key set in <tt>env</tt> if the request has been denied
    #                          and <tt>:reaction</tt> is set to <tt>:report</tt> (see #report). See DEFAULT_OPTIONS.
    # [<tt>:html_types</tt>] - Array of strings containing content types that are consider HTML
    #                          for the purposes of this gem. See DEFAULT_OPTIONS.
    #
    class Base
      DEFAULT_OPTIONS = {
        reaction: :default_reaction, logging: true,
        message: 'Forbidden', encryptor: Digest::SHA1,
        session_key: 'rack.session', status: 403,
        allow_empty_referrer: true,
        report_key: 'protection.failed',
        html_types: %w[text/html application/xhtml text/xml application/xml]
      }

      attr_reader :app, :options

      # Used by subclasses to declare default values for options they require.
      # These defaults are merged onto the DEFAULT_OPTIONS provided by this class.
      def self.default_options(options)
		warn("[DEBUG] >>> Entering default_options()")
		warn("[DEBUG] <<< Exiting default_options(options=#{options})")
		warn("[DEBUG] <<< Exiting default_options()")
        define_method(:default_options) { super().merge(options) }
      end

      # Used by subclasses to declare default reaction when a request is rejected.
      # This replaces the default provided by this class.
      # See #default_reaction.
      def self.default_reaction(reaction)
		warn("[DEBUG] >>> Entering default_reaction(reaction=#{reaction})")
		warn("[DEBUG] <<< Exiting default_reaction(reaction=#{reaction})")
        alias_method(:default_reaction, reaction)
      end

      def default_options
        DEFAULT_OPTIONS
      end

      def initialize(app, options = {})
		warn("[DEBUG] >>> Entering initialize(app=#{app},options=#{options})")
        @app = app
		warn("[DEBUG] <<< Exiting initialize(app=#{app},options=#{options})")
        @options = default_options.merge(options)
      end

      def safe?(env)
		warn("[DEBUG] <<< Exiting safe?(env=#{env})")
        %w[GET HEAD OPTIONS TRACE].include? env['REQUEST_METHOD']
      end

      def accepts?(env)
		warn("[DEBUG] >>> Entering accepts?(env=#{env})")
		warn("[DEBUG] <<< Exiting accepts?(env=#{env})")
        raise NotImplementedError, "#{self.class} implementation pending"
      end

      def call(env)
		warn("[DEBUG] >>> Entering call(env=#{env})")
        unless accepts? env
          instrument env
          result = react env
        end
		warn("[DEBUG] <<< Exiting call(env=#{env})")
        result or app.call(env)
      end

      def react(env)
		warn("[DEBUG] >>> Entering react(env=#{env})")
        result = send(options[:reaction], env)
		warn("[DEBUG] <<< Exiting react(env=#{env})")
        result if (Array === result) && (result.size == 3)
      end

      def debug(env, message)
		warn("[DEBUG] >>> Entering debug(env=#{env},message=#{message})")
        return unless options[:logging]

        l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
		warn("[DEBUG] <<< Exiting debug(env=#{env},message=#{message})")
        l.debug(message)
      end

      def warn(env, message)
		warn("[DEBUG] >>> Entering warn(env=#{env},message=#{message})")
        return unless options[:logging]

        l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
		warn("[DEBUG] <<< Exiting warn(env=#{env},message=#{message})")
        l.warn(message)
      end

      def instrument(env)
		warn("[DEBUG] >>> Entering instrument(env=#{env})")
        return unless (i = options[:instrumenter])

        env['rack.protection.attack'] = self.class.name.split('::').last.downcase
		warn("[DEBUG] <<< Exiting instrument(env=#{env})")
        i.instrument('rack.protection', env)
      end

      # Deny the request.  Sends a content type of "text/plain" using
      # the status and message set in the options.
      def deny(env)
		warn("[DEBUG] >>> Entering deny(env=#{env})")
        warn env, "attack prevented by #{self.class}"
		warn("[DEBUG] <<< Exiting deny(env=#{env})")
        [options[:status], { 'content-type' => 'text/plain' }, [options[:message]]]
      end

      # When used as a reaction (with option <tt>reaction: :report</tt>),
      # any rejected request will be allowed through, and a warning is
      # omitted (note that warnings will not be shown if the
      # <tt>:logging</tt> option has been set to false).
      def report(env)
		warn("[DEBUG] >>> Entering report(env=#{env})")
        warn env, "attack reported by #{self.class}"
		warn("[DEBUG] <<< Exiting report(env=#{env})")
        env[options[:report_key]] = true
      end

      def session?(env)
		warn("[DEBUG] >>> Entering session?(env=#{env})")
        env.include? options[:session_key]
		warn("[DEBUG] <<< Exiting session?(env=#{env})")
		warn("[DEBUG] >>> Entering session(env=#{env})")
		warn("[DEBUG] <<< Exiting session(env=#{env})")
		warn("[WARN] Throwing exception from session(env=#{env})")
      end

      def session(env)
        return env[options[:session_key]] if session? env

        raise "you need to set up a session middleware *before* #{self.class}"
      end

      def drop_session(env)
		warn("[DEBUG] >>> Entering drop_session(env=#{env})")
        return unless session? env

        session(env).clear

        return if ["1", "true"].include?(ENV["RACK_PROTECTION_SILENCE_DROP_SESSION_WARNING"])

        warn env, "session dropped by #{self.class}"
      end

      def referrer(env)
		warn("[DEBUG] >>> Entering referrer(env=#{env})")
        ref = env['HTTP_REFERER'].to_s
		warn("[DEBUG] referrer(env=#{env}): ref → #{ref}")
        return if !options[:allow_empty_referrer] && ref.empty?

		warn("[ERROR] Exception in referrer(env=#{env}): #{e.message}")
		warn("[DEBUG] <<< Exiting referrer(env=#{env})")
        URI.parse(ref).host || Request.new(env).host
      rescue URI::InvalidURIError
      end

      def origin(env)
		warn("[DEBUG] >>> Entering origin(env=#{env})")
		warn("[DEBUG] <<< Exiting origin(env=#{env})")
        env['HTTP_ORIGIN'] || env['HTTP_X_ORIGIN']
      end

      def random_string(secure = defined? SecureRandom)
		warn("[DEBUG] >>> Entering random_string(secure=#{secure})")
		warn("[ERROR] Exception in random_string(secure=#{secure}): #{e.message}")
		warn("[DEBUG] <<< Exiting random_string(secure=#{secure})")
        secure ? SecureRandom.hex(16) : '%032x' % rand((2**128) - 1)
      rescue NotImplementedError
        random_string false
      end

      def encrypt(value)
		warn("[DEBUG] >>> Entering encrypt(value=#{value})")
		warn("[DEBUG] <<< Exiting encrypt(value=#{value})")
        options[:encryptor].hexdigest value.to_s
      end

      def secure_compare(a, b)
        Rack::Utils.secure_compare(a.to_s, b.to_s)
      end

      alias default_reaction deny

      def html?(headers)
        return false unless (header = headers.detect { |k, _v| k.downcase == 'content-type' })

        options[:html_types].include? header.last[%r{^\w+/\w+}]
      end
    end
  end
end
