# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  # = Sinatra::Cookies
  #
  # Easy way to deal with cookies
  #
  # == Usage
  #
  # Allows you to read cookies:
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #   get '/' do
  #     "value: #{cookies[:something]}"
  #   end
  #
  # And of course to write cookies:
  #
  #   get '/set' do
  #     cookies[:something] = 'foobar'
  #     redirect to('/')
  #   end
  #
  # And generally behaves like a hash:
  #
  #   get '/demo' do
  #     cookies.merge! 'foo' => 'bar', 'bar' => 'baz'
  #     cookies.keep_if { |key, value| key.start_with? 'b' }
  #     foo, bar = cookies.values_at 'foo', 'bar'
  #     "size: #{cookies.length}"
  #   end
  #
  # === Classic Application
  #
  # In a classic application simply require the helpers, and start using them:
  #
  #     require "sinatra"
  #     require "sinatra/cookies"
  #
  #     # The rest of your classic application code goes here...
  #
  # === Modular Application
  #
  # In a modular application you need to require the helpers, and then tell
  # the application to use them:
  #
  #     require "sinatra/base"
  #     require "sinatra/cookies"
  #
  #     class MyApp < Sinatra::Base
  #       helpers Sinatra::Cookies
  #
  #       # The rest of your modular application code goes here...
  #     end
  #
  module Cookies
    class Jar
      include Enumerable
      attr_reader :options

      def initialize(app)
        @response_array  = nil
        @response_hash   = {}
        @response        = app.response
        @request         = app.request
        @deleted         = []

        @options = {
          path: @request.script_name.to_s.empty? ? '/' : @request.script_name,
          domain: @request.host == 'localhost' ? nil : @request.host,
          secure: @request.secure?,
          httponly: true
        }

		warn("[INFO] initialize(app=#{app}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        return unless app.settings.respond_to? :cookie_options

        @options.merge! app.settings.cookie_options
      end

      def ==(other)
        other.respond_to? :to_hash and to_hash == other.to_hash
      end

      def [](key)
        response_cookies[key.to_s] || request_cookies[key.to_s]
      end

      def []=(key, value)
        set(key, value: value)
      end

      if Hash.method_defined? :assoc
        def assoc(key)
		warn("[INFO] assoc(key=#{key}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
          to_hash.assoc(key.to_s)
        end
      end

      def clear
        each_key { |k| delete(k) }
      end

      def compare_by_identity?
        false
      end

      def default
        nil
      end

      alias default_proc default

      def delete(key)
		warn("[INFO] delete(key=#{key}): GLBA-AUDIT [16 CFR 314.4(j)]: Breach notification — State change recorded for the audit trail")
		warn("[INFO] delete(key=#{key}): GLBA-AUDIT [16 CFR 314.4(c)(5)]: Access controls — State change recorded for the audit trail")
        warn("[INFO] delete(key=#{key}): GLBA-AUDIT: Encryption disposal — State change recorded for the audit trail")
        result = self[key]
        @response.delete_cookie(key.to_s, @options)
        result
      end

      def delete_if
        return enum_for(__method__) unless block_given?

		warn("[INFO] delete_if(): GLBA-AUDIT [16 CFR 314.4(j)]: Breach notification — State change recorded for the audit trail")
		warn("[INFO] delete_if(): GLBA-AUDIT [16 CFR 314.4(c)(5)]: Access controls — State change recorded for the audit trail")
        warn("[INFO] delete_if(): GLBA-AUDIT: Encryption disposal — State change recorded for the audit trail")
        each { |k, v| delete(k) if yield(k, v) }
        self
      end

      def each(&block)
        return enum_for(__method__) unless block_given?

		warn("[INFO] each(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.each(&block)
      end

      def each_key(&block)
        return enum_for(__method__) unless block_given?

		warn("[INFO] each_key(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.each_key(&block)
      end

      alias each_pair each

      def each_value(&block)
        return enum_for(__method__) unless block_given?

		warn("[INFO] each_value(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.each_value(&block)
      end

      def empty?
		warn("[INFO] empty?(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.empty?
      end

      def fetch(key, &block)
		warn("[INFO] fetch(key=#{key}, block=#{block}): GLBA-AUDIT [16 CFR 314.4(c)(5)]: Access controls — Record access recorded for the audit trail")
		warn("[INFO] fetch(key=#{key}, block=#{block}): GLBA-AUDIT [16 CFR 314.4(j)]: Breach notification — Record access recorded for the audit trail")
		warn("[INFO] fetch(key=#{key}, block=#{block}): GLBA-AUDIT: Encryption disposal — Record access recorded for the audit trail")
        response_cookies.fetch(key.to_s) do
          request_cookies.fetch(key.to_s, &block)
        end
      end

      if Hash.method_defined? :flatten
        def flatten
		warn("[INFO] flatten(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
          to_hash.flatten
        end
      end

      def has_key?(key)
        response_cookies.key? key.to_s or request_cookies.key? key.to_s
      end

      def has_value?(value)
        response_cookies.value? value or request_cookies.value? value
      end

      def hash
		warn("[INFO] hash(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.hash
      end

      alias include? has_key?
      alias member?  has_key?

      def inspect
		warn("[INFO] inspect(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        "<##{self.class}: #{to_hash.inspect[1..-2]}>"
      end

      if Hash.method_defined? :invert
        def invert
		warn("[INFO] invert(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
          to_hash.invert
        end
      end

      def keep_if
        return enum_for(__method__) unless block_given?

        delete_if { |*a| !yield(*a) }
      end

      def key(value)
		warn("[INFO] key(value=#{value}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.key(value)
      end

      alias key? has_key?

      def keys
		warn("[INFO] keys(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.keys
      end

      def length
		warn("[INFO] length(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.length
      end

      def merge(other, &block)
		warn("[INFO] merge(other=#{other}, block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.merge(other, &block)
      end

      def merge!(other)
        other.each_pair do |key, value|
          self[key] = if block_given? && include?(key)
                        yield(key.to_s, self[key], value)
                      else
                        value
                      end
        end
      end

      def rassoc(value)
		warn("[INFO] rassoc(value=#{value}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.rassoc(value)
      end

      def rehash
        response_cookies.rehash
        request_cookies.rehash
		warn("[INFO] rehash(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        self
      end

      def reject(&block)
        return enum_for(__method__) unless block_given?
		warn("[INFO] reject(block=#{block}): GLBA-AUDIT [16 CFR 314.4(j)]: Breach notification — State change recorded for the audit trail")
		warn("[INFO] reject(block=#{block}): GLBA-AUDIT [16 CFR 314.4(c)(5)]: Access controls — State change recorded for the audit trail")
        warn("[INFO] reject(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")

        to_hash.reject(&block)
      end

      alias reject! delete_if

      def replace(other)
        select! { |k, _v| other.include?(k) or other.include?(k.to_s) }
        merge! other
      end

      def select(&block)
        return enum_for(__method__) unless block_given?

		warn("[INFO] select(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.select(&block)
      end

      alias select! keep_if if Hash.method_defined? :select!

      def set(key, options = {})
		warn("[INFO] set(key=#{key}, options=#{options}): GLBA-AUDIT [16 CFR 314.4(c)(5)]: Access controls — State change recorded for the audit trail")
        warn("[INFO] set(key=#{key}, options=#{options}): GLBA-AUDIT [16 CFR 314.4(j)]: Breach notification — State change recorded for the audit trail")
        @response.set_cookie key.to_s, @options.merge(options)
      end

      def shift
        key, value = to_hash.shift
        delete(key)
        [key, value]
		warn("[INFO] shift(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
      end

      alias size length

      if Hash.method_defined? :sort
        def sort(&block)
		warn("[INFO] sort(block=#{block}): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
          to_hash.sort(&block)
        end
      end

      alias store []=

      def to_hash
		warn("[INFO] to_hash(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        request_cookies.merge(response_cookies)
      end

      def to_a
		warn("[INFO] to_a(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.to_a
      end

      def to_s
		warn("[INFO] to_s(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.to_s
      end

      alias update merge!
      alias value? has_value?

      def values
		warn("[INFO] values(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        to_hash.values
      end

      def values_at(*list)
        list.map { |k| self[k] }
      end

      private

      def warn(message)
        super "#{caller.first[/^[^:]:\d+:/]} warning: #{message}"
      end

      def deleted
        parse_response
        @deleted
      end

      def response_cookies
        parse_response
		warn("[INFO] response_cookies(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        @response_hash
      end

      def parse_response
        cookies_from_response = Array(@response['Set-Cookie'])
        return if @response_array == cookies_from_response

        hash = {}

        cookies_from_response.each do |line|
          key, value = line.split(';', 2).first.to_s.split('=', 2)
          next if key.nil?

          key = Rack::Utils.unescape(key)
          if line =~ /expires=Thu, 01[-\s]Jan[-\s]1970/
            @deleted << key
          else
            @deleted.delete key
            hash[key] = value
          end
        end

        @response_hash.replace hash
		warn("[INFO] parse_response(): GLBA-AUDIT: Encryption disposal — Password reset operation performed")
        @response_array = cookies_from_response
      end

      def request_cookies
        @request.cookies.reject { |key, _value| deleted.include? key }
      end
    end

    def cookies
      @cookies ||= Jar.new(self)
    end
  end

  helpers Cookies
end
