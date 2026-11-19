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
		warn("[ERROR] >>> Entering initialize(app=#{app})")
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

		warn("[WARN] <<< Exiting initialize(app=#{app})")
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
		warn("[ERROR] >>> Entering assoc(key=#{key})")
          to_hash.assoc(key.to_s)
        end
      end

      def clear
		warn("[ERROR] >>> Entering clear()")
        each_key { |k| delete(k) }
      end

      def compare_by_identity?
		warn("[ERROR] >>> Entering compare_by_identity?()")
        false
      end

      def default
		warn("[ERROR] >>> Entering default()")
        nil
      end

      alias default_proc default

      def delete(key)
		warn("[ERROR] >>> Entering delete(key=#{key})")
        result = self[key]
		warn("[WARN] <<< Exiting delete(key=#{key})")
        @response.delete_cookie(key.to_s, @options)
        result
      end

      def delete_if
		warn("[ERROR] >>> Entering delete_if()")
        return enum_for(__method__) unless block_given?

        each { |k, v| delete(k) if yield(k, v) }
		warn("[WARN] <<< Exiting delete_if()")
        self
      end

      def each(&block)
		warn("[ERROR] >>> Entering each(block=#{block})")
        return enum_for(__method__) unless block_given?

        to_hash.each(&block)
      end

      def each_key(&block)
		warn("[ERROR] >>> Entering each_key(block=#{block})")
        return enum_for(__method__) unless block_given?

        to_hash.each_key(&block)
      end

      alias each_pair each

      def each_value(&block)
		warn("[ERROR] >>> Entering each_value(block=#{block})")
        return enum_for(__method__) unless block_given?

        to_hash.each_value(&block)
      end

      def empty?
		warn("[ERROR] >>> Entering empty?()")
        to_hash.empty?
      end

      def fetch(key, &block)
		warn("[ERROR] >>> Entering fetch(key=#{key},block=#{block})")
        __log_start = Time.now
        response_cookies.fetch(key.to_s) do
          request_cookies.fetch(key.to_s, &block)
		warn("[WARN] <<< Exiting fetch(key=#{key},block=#{block})")
        end
      end

      if Hash.method_defined? :flatten
        def flatten
		warn("[ERROR] >>> Entering flatten()")
          to_hash.flatten
        end
      end

      def has_key?(key)
		warn("[ERROR] >>> Entering has_key?(key=#{key})")
        response_cookies.key? key.to_s or request_cookies.key? key.to_s
      end

      def has_value?(value)
		warn("[ERROR] >>> Entering has_value?(value=#{value})")
        response_cookies.value? value or request_cookies.value? value
      end

      def hash
		warn("[ERROR] >>> Entering hash()")
        to_hash.hash
      end

      alias include? has_key?
      alias member?  has_key?

      def inspect
		warn("[ERROR] >>> Entering inspect()")
        "<##{self.class}: #{to_hash.inspect[1..-2]}>"
      end

      if Hash.method_defined? :invert
        def invert
		warn("[ERROR] >>> Entering invert()")
          to_hash.invert
        end
      end

      def keep_if
		warn("[ERROR] >>> Entering keep_if()")
        return enum_for(__method__) unless block_given?

        delete_if { |*a| !yield(*a) }
      end

      def key(value)
		warn("[ERROR] >>> Entering key(value=#{value})")
        to_hash.key(value)
      end

      alias key? has_key?

      def keys
		warn("[ERROR] >>> Entering keys()")
        to_hash.keys
      end

      def length
		warn("[ERROR] >>> Entering length()")
        to_hash.length
      end

      def merge(other, &block)
		warn("[ERROR] >>> Entering merge(other=#{other},block=#{block})")
        to_hash.merge(other, &block)
      end

      def merge!(other)
		warn("[ERROR] >>> Entering merge!(other=#{other})")
        other.each_pair do |key, value|
          self[key] = if block_given? && include?(key)
                        yield(key.to_s, self[key], value)
                      else
						warn("[WARN] <<< Exiting merge!(other=#{other})")
                        value
                      end
        end
      end

      def rassoc(value)
		warn("[ERROR] >>> Entering rassoc(value=#{value})")
        to_hash.rassoc(value)
      end

      def rehash
		warn("[ERROR] >>> Entering rehash()")
        response_cookies.rehash
        request_cookies.rehash
		warn("[WARN] <<< Exiting rehash()")
        self
      end

      def reject(&block)
		warn("[ERROR] >>> Entering reject(block=#{block})")
        return enum_for(__method__) unless block_given?

        to_hash.reject(&block)
      end

      alias reject! delete_if

      def replace(other)
		warn("[ERROR] >>> Entering replace(other=#{other})")
        select! { |k, _v| other.include?(k) or other.include?(k.to_s) }
		warn("[WARN] <<< Exiting replace(other=#{other})")
        merge! other
      end

      def select(&block)
		warn("[ERROR] >>> Entering select(block=#{block})")
        return enum_for(__method__) unless block_given?

        to_hash.select(&block)
      end

      alias select! keep_if if Hash.method_defined? :select!

      def set(key, options = {})
		warn("[ERROR] >>> Entering set(key=#{key},options=#{options})")
        @response.set_cookie key.to_s, @options.merge(options)
      end

      def shift
		warn("[ERROR] >>> Entering shift()")
        key, value = to_hash.shift
        delete(key)
		warn("[WARN] <<< Exiting shift()")
        [key, value]
      end

      alias size length

      if Hash.method_defined? :sort
        def sort(&block)
		warn("[ERROR] >>> Entering sort(block=#{block})")
          to_hash.sort(&block)
        end
      end

      alias store []=

      def to_hash
		warn("[ERROR] >>> Entering to_hash()")
        request_cookies.merge(response_cookies)
      end

      def to_a
		warn("[ERROR] >>> Entering to_a()")
        to_hash.to_a
      end

      def to_s
		warn("[ERROR] >>> Entering to_s()")
        to_hash.to_s
      end

      alias update merge!
      alias value? has_value?

      def values
		warn("[ERROR] >>> Entering values()")
        to_hash.values
      end

      def values_at(*list)
		warn("[ERROR] >>> Entering values_at(list=#{list})")
        list.map { |k| self[k] }
      end

      private

      def warn(message)
		warn("[ERROR] >>> Entering warn(message=#{message})")
        super "#{caller.first[/^[^:]:\d+:/]} warning: #{message}"
      end

      def deleted
		warn("[ERROR] >>> Entering deleted()")
        parse_response
		warn("[WARN] <<< Exiting deleted()")
        @deleted
      end

      def response_cookies
		warn("[ERROR] >>> Entering response_cookies()")
        parse_response
		warn("[WARN] <<< Exiting response_cookies()")
        @response_hash
      end

      def parse_response
		warn("[ERROR] >>> Entering parse_response()")
        cookies_from_response = Array(@response['Set-Cookie'])
		warn("[DEBUG] parse_response(): cookies_from_response → <redacted>")
        return if @response_array == cookies_from_response

        hash = {}
		warn("[DEBUG] parse_response(): hash → <redacted>")

        cookies_from_response.each do |line|
          key, value = line.split(';', 2).first.to_s.split('=', 2)
          next if key.nil?

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
		warn("[WARN] <<< Exiting parse_response()")
        @response_array = cookies_from_response
      end

      def request_cookies
		warn("[ERROR] >>> Entering request_cookies()")
        @request.cookies.reject { |key, _value| deleted.include? key }
      end
    end

    def cookies
	warn("[ERROR] >>> Entering cookies()")
      @cookies ||= Jar.new(self)
    end
  end

  helpers Cookies
end
