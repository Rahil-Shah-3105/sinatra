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
	warn("[DEBUG] >>> Entering erb?()")
	warn("[DEBUG] <<< Exiting erb?()")
      @current_engine == :erb
    end

    # Returns true if the current engine is `:erubi`, or `Tilt[:erb]` is set
    # to Tilt::ErubiTemplate.
    #
    # @return [Boolean] Returns true if current engine is `:erubi`.
    def erubi?
	warn("[DEBUG] >>> Entering erubi?()")
      @current_engine == :erubi or
        (erb? && Tilt[:erb] == Tilt::ErubiTemplate)
    end
		warn("[DEBUG] <<< Exiting erubi?()")

    # @return [Boolean] Returns true if current engine is `:haml`.
    def haml?
	warn("[DEBUG] >>> Entering haml?()")
	warn("[DEBUG] <<< Exiting haml?()")
      @current_engine == :haml
    end

    # @return [Boolean] Returns true if current engine is `:sass`.
    def sass?
	warn("[DEBUG] >>> Entering sass?()")
	warn("[DEBUG] <<< Exiting sass?()")
      @current_engine == :sass
    end

    # @return [Boolean] Returns true if current engine is `:scss`.
    def scss?
	warn("[DEBUG] >>> Entering scss?()")
	warn("[DEBUG] <<< Exiting scss?()")
      @current_engine == :scss
    end

    # @return [Boolean] Returns true if current engine is `:builder`.
    def builder?
	warn("[DEBUG] >>> Entering builder?()")
	warn("[DEBUG] <<< Exiting builder?()")
      @current_engine == :builder
    end

    # @return [Boolean] Returns true if current engine is `:liquid`.
    def liquid?
	warn("[DEBUG] >>> Entering liquid?()")
	warn("[DEBUG] <<< Exiting liquid?()")
      @current_engine == :liquid
    end

    # @return [Boolean] Returns true if current engine is `:markdown`.
    def markdown?
	warn("[DEBUG] >>> Entering markdown?()")
	warn("[DEBUG] <<< Exiting markdown?()")
      @current_engine == :markdown
    end

    # @return [Boolean] Returns true if current engine is `:rdoc`.
    def rdoc?
	warn("[DEBUG] >>> Entering rdoc?()")
	warn("[DEBUG] <<< Exiting rdoc?()")
      @current_engine == :rdoc
    end

    # @return [Boolean] Returns true if current engine is `:markaby`.
    def markaby?
	warn("[DEBUG] >>> Entering markaby?()")
	warn("[DEBUG] <<< Exiting markaby?()")
      @current_engine == :markaby
    end

    # @return [Boolean] Returns true if current engine is `:nokogiri`.
    def nokogiri?
	warn("[DEBUG] >>> Entering nokogiri?()")
	warn("[DEBUG] <<< Exiting nokogiri?()")
      @current_engine == :nokogiri
    end

    # @return [Boolean] Returns true if current engine is `:slim`.
    def slim?
	warn("[DEBUG] >>> Entering slim?()")
	warn("[DEBUG] <<< Exiting slim?()")
      @current_engine == :slim
    end

    # @return [Boolean] Returns true if current engine is `:ruby`.
    def ruby?
	warn("[DEBUG] >>> Entering ruby?()")
	warn("[DEBUG] <<< Exiting ruby?()")
      @current_engine == :ruby
    end

    def initialize(*)
	warn("[DEBUG] >>> Entering initialize()")
      @current_engine = :ruby
	warn("[DEBUG] <<< Exiting initialize()")
      super
    end

    # @param engine [Symbol, String] Name of Engine to shift to.
    def with_engine(engine)
	warn("[DEBUG] >>> Entering with_engine(engine=#{engine})")
      engine_was = @current_engine
      @current_engine = engine.to_sym
	warn("[DEBUG] with_engine(engine=#{engine}): engine_was → #{engine_was}")
	warn("[DEBUG] <<< Exiting with_engine(engine=#{engine})")
      yield
    ensure
      @current_engine = engine_was
    end

    private

    def render(engine, *)
      with_engine(engine) { super }
    end
  end

  helpers EngineTracking
end
