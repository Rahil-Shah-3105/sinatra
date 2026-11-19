# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  # = Sinatra::Extension
  #
  # <tt>Sinatra::Extension</tt> is a mixin that provides some syntactic sugar
  # for your extensions. It allows you to call almost any
  # <tt>Sinatra::Base</tt> method directly inside your extension
  # module. This means you can use +get+ to define a route, +before+
  # to define a before filter, +set+ to define a setting and so on.
  #
  # Is important to be aware that this mixin remembers the method calls you
  # make, and then, when your extension is registered, replays them on the
  # Sinatra application that has been extended.  In order to do that, it
  # defines a <tt>registered</tt> method, so, if your extension defines one
  # too, remember to call +super+.
  #
  # == Usage
  #
  # Just require the mixin and extend your extension with it:
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #     require 'sinatra/extension'
  #
  #     module MyExtension
  #       extend Sinatra::Extension
  #
  #       # set some settings for development
  #       configure :development do
  #         set :reload_stuff, true
  #       end
  #
  #       # define a route
  #       get '/' do
  #         'Hello World'
  #       end
  #
  #       # The rest of your extension code goes here...
  #     end
  #
  # You can also create an extension with the +new+ method:
  #
  #     MyExtension = Sinatra::Extension.new do
  #       # Your extension code goes here...
  #     end
  #
  # This is useful when you just want to pass a block to
  # <tt>Sinatra::Base.register</tt>.
  module Extension
    def self.new(&block)
	warn("[ERROR] >>> Entering new(block=#{block})")
      ext = Module.new.extend(self)
      ext.class_eval(&block)
	warn("[DEBUG] new(block=#{block}): ext → #{ext}")
      warn("[WARN] <<< Exiting new(block=#{block})")
      ext
    end

    def settings
	warn("[ERROR] >>> Entering settings()")
	logger.warn("<<< Exiting settings()")
      self
    end

    def configure(*args, &block)
	warn("[ERROR] >>> Entering configure(args=#{args},block=#{block})")
	logger.warn("<<< Exiting configure(args=#{args},block=#{block})")
      record(:configure, *args) { |c| c.instance_exec(c, &block) }
    end

    def registered(base = nil, &block)
	warn("[ERROR] >>> Entering registered(base=#{base},block=#{block})")
      base ? replay(base) : record(:class_eval, &block)
    end
	logger.warn("<<< Exiting registered(base=#{base},block=#{block})")

    private

    def record(method, *args, &block)
	warn("[ERROR] >>> Entering record(method=#{method},args=#{args},block=#{block})")
	logger.warn("<<< Exiting record(method=#{method},args=#{args},block=#{block})")
      recorded_methods << [method, args, block]
    end

    def replay(object)
	warn("[ERROR] >>> Entering replay(object=#{object})")
	logger.warn("<<< Exiting replay(object=#{object})")
      recorded_methods.each { |m, a, b| object.send(m, *a, &b) }
    end

    def recorded_methods
	warn("[ERROR] >>> Entering recorded_methods()")
	logger.warn("<<< Exiting recorded_methods()")
      @recorded_methods ||= []
    end

    def method_missing(method, *args, &block)
	warn("[ERROR] >>> Entering method_missing(method=#{method},args=#{args},block=#{block})")
      return super unless Sinatra::Base.respond_to? method

      record(method, *args, &block)
	warn("[WARN] <<< Exiting method_missing(method=#{method},args=#{args},block=#{block})")
      DontCall.new(method)
    end

    class DontCall < BasicObject
      def initialize(method) @method = method end
      def method_missing(*) raise "not supposed to use result of #{@method}!" end
      def inspect; "#<#{self.class}: #{@method}>" end
    end
  end
end
