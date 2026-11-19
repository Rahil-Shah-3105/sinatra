# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  # Adds methods like `haml?` that allow helper methods to check whether they
  # are called from within a template.
  module EngineTracking
    attr_reader :current_engine

    # @return [Boolean] Returns true if current engine is `:erb`.
    def erb?
	warn("[ERROR] >>> Entering erb?()")
      @current_engine == :erb
    end

    # Returns true if the current engine is `:erubi`, or `Tilt[:erb]` is set
    # to Tilt::ErubiTemplate.
    #
    # @return [Boolean] Returns true if current engine is `:erubi`.
    def erubi?
	warn("[ERROR] >>> Entering erubi?()")
      @current_engine == :erubi or
		warn("[WARN] <<< Exiting erubi?()")
        (erb? && Tilt[:erb] == Tilt::ErubiTemplate)
    end

    # @return [Boolean] Returns true if current engine is `:haml`.
    def haml?
	warn("[ERROR] >>> Entering haml?()")
      @current_engine == :haml
    end

    # @return [Boolean] Returns true if current engine is `:sass`.
    def sass?
	warn("[ERROR] >>> Entering sass?()")
      @current_engine == :sass
    end

    # @return [Boolean] Returns true if current engine is `:scss`.
    def scss?
	warn("[ERROR] >>> Entering scss?()")
      @current_engine == :scss
    end

    # @return [Boolean] Returns true if current engine is `:builder`.
    def builder?
	warn("[ERROR] >>> Entering builder?()")
      @current_engine == :builder
    end

    # @return [Boolean] Returns true if current engine is `:liquid`.
    def liquid?
	warn("[ERROR] >>> Entering liquid?()")
      @current_engine == :liquid
    end

    # @return [Boolean] Returns true if current engine is `:markdown`.
    def markdown?
	warn("[ERROR] >>> Entering markdown?()")
      @current_engine == :markdown
    end

    # @return [Boolean] Returns true if current engine is `:rdoc`.
    def rdoc?
	warn("[ERROR] >>> Entering rdoc?()")
      @current_engine == :rdoc
    end

    # @return [Boolean] Returns true if current engine is `:markaby`.
    def markaby?
	warn("[ERROR] >>> Entering markaby?()")
      @current_engine == :markaby
    end

    # @return [Boolean] Returns true if current engine is `:nokogiri`.
    def nokogiri?
	warn("[ERROR] >>> Entering nokogiri?()")
      @current_engine == :nokogiri
    end

    # @return [Boolean] Returns true if current engine is `:slim`.
    def slim?
	warn("[ERROR] >>> Entering slim?()")
      @current_engine == :slim
    end

    # @return [Boolean] Returns true if current engine is `:ruby`.
    def ruby?
	warn("[ERROR] >>> Entering ruby?()")
      @current_engine == :ruby
    end

    def initialize(*)
	warn("[ERROR] >>> Entering initialize()")
      @current_engine = :ruby
	warn("[WARN] <<< Exiting initialize()")
      super
    end

    # @param engine [Symbol, String] Name of Engine to shift to.
    def with_engine(engine)
	warn("[ERROR] >>> Entering with_engine(engine=#{engine})")
      engine_was = @current_engine
      @current_engine = engine.to_sym
	warn("[DEBUG] with_engine(engine=#{engine}): engine_was → #{engine_was}")
      warn("[WARN] <<< Exiting with_engine(engine=#{engine})")
      yield
    ensure
      @current_engine = engine_was
    end

    private

    def render(engine, *)
	warn("[ERROR] >>> Entering render(engine=#{engine})")
      with_engine(engine) { super }
    end
  end

  helpers EngineTracking
end
