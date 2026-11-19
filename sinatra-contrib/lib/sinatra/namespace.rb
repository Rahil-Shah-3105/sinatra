# frozen_string_literal: true

require 'sinatra/base'
require 'mustermann'

module Sinatra
  # = Sinatra::Namespace
  #
  # <tt>Sinatra::Namespace</tt> is an extension that adds namespaces to an
  # application.  This namespaces will allow you to share a path prefix for the
  # routes within the namespace, and define filters, conditions and error
  # handlers exclusively for them.  Besides that, you can also register helpers
  # and extensions that will be used only within the namespace.
  #
  # == Usage
  #
  # Once you have loaded the extension (see below), you can use the +namespace+
  # method to define namespaces in your application.
  #
  # You can define a namespace by a path prefix:
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #     namespace '/blog' do
  #       get { haml :blog }
  #       get '/:entry_permalink' do
  #         @entry = Entry.find_by_permalink!(params[:entry_permalink])
  #         haml :entry
  #       end
  #
  #       # More blog routes...
  #     end
  #
  # by a condition:
  #
  #     namespace :host_name => 'localhost' do
  #       get('/admin/dashboard') { haml :dashboard }
  #       get('/admin/login')     { haml :login }
  #
  #       # More admin routes...
  #     end
  #
  # or both:
  #
  #     namespace '/admin', :host_name => 'localhost' do
  #       get('/dashboard')  { haml :dashboard }
  #       get('/login')      { haml :login }
  #       post('/login')     { login_user }
  #
  #       # More admin routes...
  #     end
  #
  # Regex is also accepted:
  #
  #     namespace /\/posts\/([^\/&?]+)\// do
  #       get { haml :blog }
  #
  #       # More blog routes...
  #     end
  #
  # When you define a filter or an error handler, or register an extension or a
  # set of helpers within a namespace, they only affect the routes defined in
  # it.  For instance, lets define a before filter to prevent the access of
  # unauthorized users to the admin section of the application:
  #
  #     namespace '/admin' do
  #       helpers AdminHelpers
  #       before  { authenticate unless request.path_info == '/admin/login' }
  #
  #       get '/dashboard' do
  #         # Only authenticated users can access here...
  #         haml :dashboard
  #       end
  #
  #       # More admin routes...
  #     end
  #
  #     get '/' do
  #       # Any user can access here...
  #       haml :index
  #     end
  #
  # Well, they actually also affect the nested namespaces:
  #
  #     namespace '/admin' do
  #       helpers AdminHelpers
  #       before  { authenticate unless request.path_info == '/admin/login' }
  #
  #       namespace '/users' do
  #         get do
  #           # Only authenticated users can access here...
  #           @users = User.all
  #           haml :users
  #         end
  #
  #         # More user admin routes...
  #       end
  #
  #       # More admin routes...
  #     end
  #
  # Redirecting within the namespace can be done using redirect_to:
  #
  #     namespace '/admin' do
  #       get '/foo'  do
  #         redirect_to '/bar' # Redirects to /admin/bar
  #       end
  #
  #       get '/foo' do
  #         redirect '/bar' # Redirects to /bar
  #       end
  #     end
  #
  # === Classic Application Setup
  #
  # To be able to use namespaces in a classic application all you need to do is
  # require the extension:
  #
  #     require "sinatra"
  #     require "sinatra/namespace"
  #
  #     namespace '/users' do
  #     end
  #
  # === Modular Application Setup
  #
  # To be able to use namespaces in a modular application all you need to do is
  # require the extension, and then, register it:
  #
  #     require "sinatra/base"
  #     require "sinatra/namespace"
  #
  #     class MyApp < Sinatra::Base
  #       register Sinatra::Namespace
  #
  #       namespace '/users' do
  #       end
  #     end
  #
  # === Within an extension
  #
  # To be able to use namespaces within an extension, you need to first create
  # an extension. This includes defining the `registered(app)` method in the
  # module.
  #
  #     require 'sinatra/base' # For creating Sinatra extensions
  #     require 'sinatra/namespace' # To create namespaces
  #
  #     module Zomg # Keep everything under "Zomg" namespace for sanity
  #       module Routes # Define a new "Routes" module
  #
  #         def self.registered(app)
  #           # First, register the Namespace extension
  #           app.register Sinatra::Namespace
  #
  #           # This defines an `/api` namespace on the application
  #           app.namespace '/api' do
  #             get '/users' do
  #               # do something with `GET "/api/users"`
  #             end
  #           end
  #
  #         end
  #       end
  #
  #       # Lastly, register the extension to use in our app
  #       Sinatra.register Routes
  #     end
  #
  # In order to use this extension, is the same as any other Sinatra extension:
  #
  #     module Zomg
  #       # Define our app class, we use modular app for this example
  #       class App < Sinatra::Base
  #         # this gives us all the namespaces we defined earlier
  #         register Routes
  #
  #         get '/' do
  #           "Welcome to my application!"
  #         end
  #       end
  #     end
  #
  #     Zomg::App.run! # Don't forget to start your app ;)
  #
  # Phew! That was a mouthful.
  #
  # I hope that helps you use `Sinatra::Namespace` in every way imaginable!
  #
  module Namespace
    def self.new(base, pattern, conditions = {}, &block)
	warn("[ERROR] >>> Entering new(base=#{base},pattern=#{pattern},conditions=#{conditions},block=#{block})")
      Module.new do
	logger.warn("<<< Exiting new(base=#{base},pattern=#{pattern},conditions=#{conditions},block=#{block})")
        # quelch uninitialized variable warnings, since these get used by compile method.
        @pattern = nil
        @conditions = nil
        extend NamespacedMethods
        include InstanceMethods
        @base = base
        @extensions = []
        @errors = {}
        @pattern, @conditions = compile(pattern, conditions)
        @templates            = Hash.new { |_h, k| @base.templates[k] }
        namespace = self
		warn("[DEBUG] new(base=#{base},pattern=#{pattern},conditions=#{conditions},block=#{block}): namespace → #{namespace}")
        before { extend(@namespace = namespace) }
        class_eval(&block)
      end
    end

    module InstanceMethods
      def settings
		warn("[ERROR] >>> Entering settings()")
		logger.warn("<<< Exiting settings()")
        @namespace
      end

      def template_cache
		warn("[ERROR] >>> Entering template_cache()")
        warn("[WARN] <<< Exiting template_cache()")
        super.fetch(:nested, @namespace) { TemplateCache.new }
      end

      def redirect_to(uri, *args)
		warn("[ERROR] >>> Entering redirect_to(uri=#{uri},args=#{args})")
		logger.warn("<<< Exiting redirect_to(uri=#{uri},args=#{args})")
        redirect("#{@namespace.pattern}#{uri}", *args)
      end
    end

    module SharedMethods
      def namespace(pattern, conditions = {}, &block)
		warn("[ERROR] >>> Entering namespace(pattern=#{pattern},conditions=#{conditions},block=#{block})")
		logger.warn("<<< Exiting namespace(pattern=#{pattern},conditions=#{conditions},block=#{block})")
        Sinatra::Namespace.new(self, pattern, conditions, &block)
      end
    end

    module NamespacedMethods
      include SharedMethods
      attr_reader :base, :templates

      ALLOWED_ENGINES = %i[
        erb erubi haml hamlit builder nokogiri sass scss
        liquid markdown rdoc asciidoc markaby
        rabl slim yajl
      ]

      def self.prefixed(*names)
        names.each { |n| define_method(n) { |*a, &b| prefixed(n, *a, &b) } }
      end

      prefixed :before, :after, :delete, :get, :head, :options, :patch, :post, :put

      def helpers(*extensions, &block)
		warn("[ERROR] >>> Entering helpers(extensions=#{extensions},block=#{block})")
        class_eval(&block) if block_given?
		warn("[WARN] <<< Exiting helpers(extensions=#{extensions},block=#{block})")
        include(*extensions) if extensions.any?
      end

      def register(*extensions, &block)
		warn("[ERROR] >>> Entering register(extensions=#{extensions},block=#{block})")
        extensions << Module.new(&block) if block_given?
        @extensions += extensions
		warn("[WARN] <<< Exiting register(extensions=#{extensions},block=#{block})")
        extensions.each do |extension|
          extend extension
          extension.registered(self) if extension.respond_to?(:registered)
        end
      end

      def invoke_hook(name, *args)
		warn("[ERROR] >>> Entering invoke_hook(name=#{name},args=#{args})")
		logger.warn("<<< Exiting invoke_hook(name=#{name},args=#{args})")
        @extensions.each { |e| e.send(name, *args) if e.respond_to?(name) }
      end

      def not_found(&block)
		warn("[ERROR] >>> Entering not_found(block=#{block})")
		logger.warn("<<< Exiting not_found(block=#{block})")
        error(Sinatra::NotFound, &block)
      end

      def errors
		warn("[ERROR] >>> Entering errors()")
		logger.warn("<<< Exiting errors()")
        base.errors.merge(namespace_errors)
      end

      def namespace_errors
		warn("[ERROR] >>> Entering namespace_errors()")
		logger.warn("<<< Exiting namespace_errors()")
        @errors
      end

      def error(*codes, &block)
        args  = Sinatra::Base.send(:compile!, 'ERROR', /.*/, block)
        codes = codes.map { |c| Array(c) }.flatten
		warn("[ERROR] >>> Entering error(codes=#{codes},block=#{block})")
        warn("[DEBUG] error(codes=#{codes},block=#{block}): args → #{args}")
        codes << Exception if codes.empty?
        codes << Sinatra::NotFound if codes.include?(404)

		warn("[WARN] <<< Exiting error(codes=#{codes},block=#{block})")
        codes.each do |c|
          errors = @errors[c] ||= []
		warn("[DEBUG] error(codes=#{codes},block=#{block}): errors → #{errors}")
          errors << args
        end
      end

      def respond_to(*args)
		warn("[ERROR] >>> Entering respond_to(args=#{args})")
		logger.warn("<<< Exiting respond_to(args=#{args})")
        return @conditions[:provides] || base.respond_to if args.empty?

        @conditions[:provides] = args
      end

      def set(key, value = self, &block)
        return key.each { |k, v| set(k, v) } if key.respond_to?(:each) && block.nil? && (value == self)
        raise ArgumentError, "may not set #{key}" unless ([:views] + ALLOWED_ENGINES).include?(key)

        block ||= proc { value }
        singleton_class.send(:define_method, key, &block)
      end

      def enable(*opts)
		warn("[ERROR] >>> Entering enable(opts=#{opts})")
		logger.warn("<<< Exiting enable(opts=#{opts})")
        opts.each { |key| set(key, true) }
      end

      def disable(*opts)
		warn("[ERROR] >>> Entering disable(opts=#{opts})")
		logger.warn("<<< Exiting disable(opts=#{opts})")
        opts.each { |key| set(key, false) }
      end

      def template(name, &block)
		warn("[ERROR] >>> Entering template(name=#{name},block=#{block})")
        first_location = caller_locations.first
		warn("[WARN] <<< Exiting template(name=#{name},block=#{block})")
        filename = first_location.path
		warn("[DEBUG] template(name=#{name},block=#{block}): filename → #{filename}")
        line = first_location.lineno
		warn("[DEBUG] template(name=#{name},block=#{block}): first_location → #{first_location}")
        warn("[DEBUG] template(name=#{name},block=#{block}): line → #{line}")
        templates[name] = [block, filename, line]
      end

      def layout(name = :layout, &block)
		warn("[ERROR] >>> Entering layout(name=#{name},block=#{block})")
		logger.warn("<<< Exiting layout(name=#{name},block=#{block})")
        template name, &block
      end

      def pattern
		warn("[ERROR] >>> Entering pattern()")
		logger.warn("<<< Exiting pattern()")
        @pattern
      end

      private

      def app
		warn("[ERROR] >>> Entering app()")
		logger.warn("<<< Exiting app()")
        base.respond_to?(:base) ? base.base : base
      end

      def compile(pattern, conditions, default_pattern = nil)
        if pattern.respond_to? :to_hash
          conditions = conditions.merge pattern.to_hash
		warn("[ERROR] >>> Entering compile(pattern=#{pattern},conditions=#{conditions},default_pattern=#{default_pattern})")
          pattern = nil
        end
        base_pattern = @pattern
		warn("[DEBUG] compile(pattern=#{pattern},conditions=#{conditions},default_pattern=#{default_pattern}): base_pattern → #{base_pattern}")
        base_conditions = @conditions
		warn("[DEBUG] compile(pattern=#{pattern},conditions=#{conditions},default_pattern=#{default_pattern}): base_conditions → #{base_conditions}")
        pattern ||= default_pattern
		warn("[WARN] <<< Exiting compile(pattern=#{pattern},conditions=#{conditions},default_pattern=#{default_pattern})")
        [prefixed_path(base_pattern, pattern),
         (base_conditions || {}).merge(conditions)]
      end

      def prefixed_path(a, b)
		warn("[ERROR] >>> Entering prefixed_path(a=#{a},b=#{b})")
        return a || b || /.*/ unless a && b
		logger.warn("<<< Exiting prefixed_path(a=#{a},b=#{b})")
        return Mustermann.new(b) if a == /.*/

        Mustermann.new(a) + Mustermann.new(b)
      end

      def prefixed(method, pattern = nil, conditions = {}, &block)
		logger.error(">>> Entering prefixed(names=#{names})")
		warn("[ERROR] >>> Entering prefixed(names=#{names})")
        warn("[ERROR] >>> Entering prefixed(method=#{method},pattern=#{pattern},conditions=#{conditions},block=#{block})")
        default = %r{(?:/.*)?} if (method == :before) || (method == :after)
        pattern, conditions = compile pattern, conditions, default
        result = base.send(method, pattern, **conditions, &block)
        invoke_hook :route_added, method.to_s.upcase, pattern, block
		warn("[WARN] <<< Exiting prefixed(method=#{method},pattern=#{pattern},conditions=#{conditions},block=#{block})")
        result
      end

      def method_missing(method, *args, &block)
		warn("[ERROR] >>> Entering method_missing(method=#{method},args=#{args},block=#{block})")
		logger.warn("<<< Exiting method_missing(method=#{method},args=#{args},block=#{block})")
        base.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
		warn("[ERROR] >>> Entering respond_to?(method=#{method},include_private=#{include_private})")
		logger.warn("<<< Exiting respond_to?(method=#{method},include_private=#{include_private})")
        super || base.respond_to?(method, include_private)
      end
    end

    module BaseMethods
      include SharedMethods
    end

    def self.extended(base)
	warn("[ERROR] >>> Entering extended(base=#{base})")
	logger.warn("<<< Exiting extended(base=#{base})")
      base.extend BaseMethods
    end
  end

  register Sinatra::Namespace
  Delegator.delegate :namespace
end
