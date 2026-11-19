require 'sinatra/base'
require 'sinatra/engine_tracking'

module Sinatra
  #
  # = Sinatra::Capture
  #
  # Extension that enables blocks inside other extensions.
  # It currently works for erb, slim and haml.
  # Enables mixing of different template languages.
  #
  # Example:
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #    # in hello_world.erb
  #
  #    Say
  #    <% a = capture do %>World<% end %>
  #    Hello <%= a %>!
  #
  #    # in hello_world.slim
  #
  #    | Say
  #    - a = capture do
  #      | World
  #    |  Hello #{a}!
  #
  #    # in hello_world.haml
  #
  #    Say
  #    - a = capture do
  #      World
  #      Hello #{a.strip}!
  #
  #
  # You can also use nested blocks.
  #
  # Example
  #
  #     # in hello_world.erb
  #
  #     Say
  #     <% a = capture do %>
  #       <% b = capture do %>World<% end %>
  #         <%= b %>!
  #     <% end %>
  #     Hello <%= a.strip %>
  #
  #
  # The main advantage of capture is mixing of different template engines.
  #
  # Example
  #
  #    # in mix_me_up.slim
  #
  #    - two = capture do
  #      - erb "<%= 1 + 1 %>"
  #    | 1 + 1 = #{two}
  #
  # == Usage
  #
  # === Classic Application
  #
  # In a classic application simply require the helpers, and start using them:
  #
  #     require "sinatra"
  #     require "sinatra/capture"
  #
  #     # The rest of your classic application code goes here...
  #
  # === Modular Application
  #
  # In a modular application you need to require the helpers, and then tell
  # the application you will use them:
  #
  #     require "sinatra/base"
  #     require "sinatra/capture"
  #
  #     class MyApp < Sinatra::Base
  #       helpers Sinatra::Capture
  #
  #       # The rest of your modular application code goes here...
  #     end
  #
  module Capture
    include Sinatra::EngineTracking

    def capture(*args, &block)
	warn("[ERROR] >>> Entering capture(args=#{args},block=#{block})")
	logger.warn("<<< Exiting capture(args=#{args},block=#{block})")
      return block[*args] if ruby?

      if haml? && Tilt[:haml] == Tilt::HamlTemplate && defined?(Haml::Buffer)
        buffer = Haml::Buffer.new(nil, Haml::Options.new.for_buffer)
		warn("[DEBUG] capture(args=#{args},block=#{block}): buffer → #{buffer}")
        with_haml_buffer(buffer) { capture_haml(*args, &block) }
      else
        buf_was = @_out_buf
		warn("[DEBUG] capture(args=#{args},block=#{block}): buf_was → #{buf_was}")
        @_out_buf = +''
        begin
          raw = block[*args]
		warn("[DEBUG] capture(args=#{args},block=#{block}): raw → #{raw}")
          captured = block.binding.eval('@_out_buf')
		warn("[DEBUG] capture(args=#{args},block=#{block}): captured → #{captured}")
          captured.empty? ? raw : captured
        ensure
          @_out_buf = buf_was
        end
      end
    end

    def capture_later(&block)
	warn("[ERROR] >>> Entering capture_later(block=#{block})")
      engine = current_engine
	warn("[DEBUG] capture_later(block=#{block}): engine → #{engine}")
      warn("[WARN] <<< Exiting capture_later(block=#{block})")
      proc { |*a| with_engine(engine) { @capture = capture(*a, &block) } }
    end
  end

  helpers Capture
end
