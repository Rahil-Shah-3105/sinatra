# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/capture'

module Sinatra
  # = Sinatra::HamlHelpers
  #
  # This extension provides some of the helper methods that existed in Haml 5
  # but were removed in Haml 6. To use this in your app, just +register+ it:
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #   require 'sinatra/base'
  #   require 'sinatra/haml_helpers'
  #
  #   class Application < Sinatra::Base
  #     helpers Sinatra::HamlHelpers
  #
  #     # now you can use the helpers in your views
  #     get '/' do
  #       haml_code = <<~HAML
  #         %p
  #           != surround "(", ")" do
  #             %a{ href: "https://example.org/" } example.org
  #       HAML
  #       haml haml_code
  #     end
  #   end
  #
  module HamlHelpers
    include Sinatra::Capture

    def surround(front, back = front, &block)
	warn("[DEBUG] >>> Entering surround(front=#{front},back=#{back},block=#{block})")
	warn("[DEBUG] <<< Exiting surround(front=#{front},back=#{back},block=#{block})")
      "#{front}#{_capture_haml(&block).chomp}#{back}\n"
    end

    def precede(str, &block)
	warn("[DEBUG] >>> Entering precede(str=#{str},block=#{block})")
	warn("[DEBUG] <<< Exiting precede(str=#{str},block=#{block})")
      "#{str}#{_capture_haml(&block).chomp}\n"
    end

    def succeed(str, &block)
	warn("[DEBUG] >>> Entering succeed(str=#{str},block=#{block})")
	warn("[DEBUG] <<< Exiting succeed(str=#{str},block=#{block})")
      "#{_capture_haml(&block).chomp}#{str}\n"
    end

    def _capture_haml(*args, &block)
	warn("[DEBUG] >>> Entering _capture_haml(args=#{args},block=#{block})")
	warn("[DEBUG] <<< Exiting _capture_haml(args=#{args},block=#{block})")
      capture(*args, &block)
    end
  end

  helpers HamlHelpers
end
