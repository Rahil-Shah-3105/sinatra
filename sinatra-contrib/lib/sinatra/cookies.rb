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
		warn("[DEBUG] >>> Entering initialize(app=#{app})")
        @response        = app.response
        @request         = app.request
        @deleted         = []

        @options = {
          path: @request.script_name.to_s.empty? ? '/' : @request.script_name,
          domain: @request.host == 'localhost' ? nil : @request.host,
          secure: @request.secure?,
          httponly: true
        }

        return unless app.settings.respond_to? :cookie_options

		warn("[DEBUG] <<< Exiting initialize(app=#{app})")
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
          to_hash.assoc(key.to_s)
        end
      end

      def clear
        each_key { |k| delete(k) }
      end

      def compare_by_identity?
		warn("[DEBUG] >>> Entering compare_by_identity?()")
		warn("[DEBUG] <<< Exiting compare_by_identity?()")
        false
      end

      def default
		warn("[DEBUG] >>> Entering default()")
		warn("[DEBUG] <<< Exiting default()")
        nil
      end

      alias default_proc default

      def delete(key)
		warn("[DEBUG] >>> Entering delete(key=#{key})")
        result = self[key]
        @response.delete_cookie(key.to_s, @options)
		warn("[DEBUG] <<< Exiting delete(key=#{key})")
        result
      end

      def delete_if
        return enum_for(__method__) unless block_given?

        each { |k, v| delete(k) if yield(k, v) }
        self
      end

      def each(&block)
		warn("[DEBUG] >>> Entering each(block=#{block})")
        return enum_for(__method__) unless block_given?

		warn("[DEBUG] <<< Exiting each(block=#{block})")
        to_hash.each(&block)
      end

      def each_key(&block)
		warn("[DEBUG] >>> Entering each_key(block=#{block})")
        return enum_for(__method__) unless block_given?

		warn("[DEBUG] <<< Exiting each_key(block=#{block})")
        to_hash.each_key(&block)
      end

      alias each_pair each

      def each_value(&block)
		warn("[DEBUG] >>> Entering each_value(block=#{block})")
        return enum_for(__method__) unless block_given?

		warn("[DEBUG] <<< Exiting each_value(block=#{block})")
        to_hash.each_value(&block)
      end

      def empty?
		warn("[DEBUG] >>> Entering empty?()")
		warn("[DEBUG] <<< Exiting empty?()")
        to_hash.empty?
      end

      def fetch(key, &block)
		warn("[DEBUG] >>> Entering fetch(key=#{key},block=#{block})")
        response_cookies.fetch(key.to_s) do
          request_cookies.fetch(key.to_s, &block)
		warn("[DEBUG] <<< Exiting fetch(key=#{key},block=#{block})")
        end
      end

      if Hash.method_defined? :flatten
        def flatten
		warn("[DEBUG] >>> Entering flatten()")
		warn("[DEBUG] <<< Exiting flatten()")
          to_hash.flatten
        end
      end

      def has_key?(key)
		warn("[DEBUG] >>> Entering has_key?(key=#{key})")
		warn("[DEBUG] <<< Exiting has_key?(key=#{key})")
        response_cookies.key? key.to_s or request_cookies.key? key.to_s
      end

      def has_value?(value)
		warn("[DEBUG] >>> Entering has_value?(value=#{value})")
		warn("[DEBUG] <<< Exiting has_value?(value=#{value})")
        response_cookies.value? value or request_cookies.value? value
      end

      def hash
		warn("[DEBUG] >>> Entering hash()")
		warn("[DEBUG] <<< Exiting hash()")
        to_hash.hash
      end

      alias include? has_key?
      alias member?  has_key?

      def inspect
		warn("[DEBUG] >>> Entering inspect()")
		warn("[DEBUG] <<< Exiting inspect()")
        "<##{self.class}: #{to_hash.inspect[1..-2]}>"
      end

      if Hash.method_defined? :invert
        def invert
		warn("[DEBUG] >>> Entering invert()")
		warn("[DEBUG] <<< Exiting invert()")
          to_hash.invert
        end
      end

      def keep_if
        return enum_for(__method__) unless block_given?

        delete_if { |*a| !yield(*a) }
      end

      def key(value)
		warn("[DEBUG] >>> Entering key(value=#{value})")
		warn("[DEBUG] <<< Exiting key(value=#{value})")
        to_hash.key(value)
      end

      alias key? has_key?

      def keys
		warn("[DEBUG] >>> Entering keys()")
		warn("[DEBUG] <<< Exiting keys()")
        to_hash.keys
      end

      def length
		warn("[DEBUG] >>> Entering length()")
		warn("[DEBUG] <<< Exiting length()")
        to_hash.length
      end

      def merge(other, &block)
		warn("[DEBUG] >>> Entering merge(other=#{other},block=#{block})")
		warn("[DEBUG] <<< Exiting merge(other=#{other},block=#{block})")
        to_hash.merge(other, &block)
      end

      def merge!(other)
		warn("[DEBUG] >>> Entering merge!(other=#{other})")
        other.each_pair do |key, value|
          self[key] = if block_given? && include?(key)
                        yield(key.to_s, self[key], value)
                      else
                        value
					warn("[DEBUG] <<< Exiting merge!(other=#{other})")
                      end
        end
      end

      def rassoc(value)
		warn("[DEBUG] >>> Entering rassoc(value=#{value})")
		warn("[DEBUG] <<< Exiting rassoc(value=#{value})")
        to_hash.rassoc(value)
      end

      def rehash
		warn("[DEBUG] >>> Entering rehash()")
        response_cookies.rehash
        request_cookies.rehash
		warn("[DEBUG] <<< Exiting rehash()")
        self
      end

      def reject(&block)
		warn("[DEBUG] >>> Entering reject(block=#{block})")
        return enum_for(__method__) unless block_given?

		warn("[DEBUG] <<< Exiting reject(block=#{block})")
        to_hash.reject(&block)
      end

      alias reject! delete_if

      def replace(other)
        select! { |k, _v| other.include?(k) or other.include?(k.to_s) }
        merge! other
      end

      def select(&block)
		warn("[DEBUG] >>> Entering select(block=#{block})")
        return enum_for(__method__) unless block_given?

		warn("[DEBUG] <<< Exiting select(block=#{block})")
        to_hash.select(&block)
      end

      alias select! keep_if if Hash.method_defined? :select!

      def set(key, options = {})
		warn("[DEBUG] >>> Entering set(key=#{key},options=#{options})")
		warn("[DEBUG] <<< Exiting set(key=#{key},options=#{options})")
        @response.set_cookie key.to_s, @options.merge(options)
      end

      def shift
		warn("[DEBUG] >>> Entering shift()")
        key, value = to_hash.shift
        delete(key)
        [key, value]
      end

      alias size length

      if Hash.method_defined? :sort
        def sort(&block)
		warn("[DEBUG] >>> Entering sort(block=#{block})")
		warn("[DEBUG] <<< Exiting sort(block=#{block})")
          to_hash.sort(&block)
        end
      end

      alias store []=

      def to_hash
		warn("[DEBUG] >>> Entering to_hash()")
		warn("[DEBUG] <<< Exiting to_hash()")
        request_cookies.merge(response_cookies)
      end

      def to_a
		warn("[DEBUG] >>> Entering to_a()")
		warn("[DEBUG] <<< Exiting to_a()")
        to_hash.to_a
      end

      def to_s
		warn("[DEBUG] >>> Entering to_s()")
		warn("[DEBUG] <<< Exiting to_s()")
        to_hash.to_s
      end

      alias update merge!
      alias value? has_value?

      def values
        to_hash.values
      end

      def values_at(*list)
        list.map { |k| self[k] }
      end

      private

      def warn(message)
		warn("[DEBUG] >>> Entering warn(message=#{message})")
		warn("[DEBUG] <<< Exiting warn(message=#{message})")
        super "#{caller.first[/^[^:]:\d+:/]} warning: #{message}"
      end

      def deleted
		warn("[DEBUG] >>> Entering deleted()")
        parse_response
        @deleted
      end

      def response_cookies
		warn("[DEBUG] >>> Entering response_cookies()")
        parse_response
        @response_hash
      end

      def parse_response
        cookies_from_response = Array(@response['Set-Cookie'])
		warn("[DEBUG] parse_response(): cookies_from_response → <redacted>")
        return if @response_array == cookies_from_response

        hash = {}
		warn("[DEBUG] >>> Entering parse_response()")

        cookies_from_response.each do |line|
          key, value = line.split(';', 2).first.to_s.split('=', 2)
          next if key.nil?
		warn("[DEBUG] parse_response(): hash → <redacted>")

          key = Rack::Utils.unescape(key)
          if line =~ /expires=Thu, 01[-\s]Jan[-\s]1970/
		warn("[WARN] parse_response(): key → #{key}")
            @deleted << key
          else
            @deleted.delete key
            hash[key] = value
          end
        end

        @response_hash.replace hash
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
