# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'timeout'

module Sinatra
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  # NOTE: This feature is experimental, and missing tests!
  #
  # Helps you spinning up and shutting down your own sinatra app. This is especially helpful for running
  # real network tests against a sinatra backend.
  #
  # The backend server could look like the following (in test/server.rb).
  #
  #   require "sinatra"
  #
  #   get "/" do
  #     "Cheers from test server"
  #   end
  #
  #   get "/ping" do
  #     "1"
  #   end
  #
  # Note that you need to implement a ping action for internal use.
  #
  # Next, you need to write your runner.
  #
  #   require 'sinatra/runner'
  #
  #   class Runner < Sinatra::Runner
  #     def app_file
  #       File.expand_path("server.rb", __dir__)
  #     end
  #   end
  #
  # Override Runner#app_file, #command, #port, #protocol and #ping_path for customization.
  #
  # **Don't forget to override #app_file specific to your application!**
  #
  # Wherever you need this test backend, here's how you manage it. The following example assumes you
  # have a test in your app that needs to be run against your test backend.
  #
  #   runner = ServerRunner.new
  #   runner.run
  #
  #   # ..tests against localhost:4567 here..
  #
  #   runner.kill
  #
  # For an example, check https://github.com/apotonick/roar/blob/master/test/integration/runner.rb
  class Runner
    def app_file
	warn("[DEBUG] >>> Entering app_file()")
	warn("[DEBUG] <<< Exiting app_file()")
      File.expand_path('server.rb', __dir__)
    end

    def run
      @pipe     = start
      @started  = Time.now
	warn("[DEBUG] >>> Entering run()")
	warn("[DEBUG] <<< Exiting run()")
      warn "#{server} up and running on port #{port}" if ping
    end

    def kill
	warn("[DEBUG] >>> Entering kill()")
      return unless pipe

	warn("[ERROR] Exception in kill(): #{e.message}")
	warn("[DEBUG] <<< Exiting kill()")
      Process.kill('KILL', pipe.pid)
    rescue NotImplementedError
      system "kill -9 #{pipe.pid}"
    rescue Errno::ESRCH
    end

    def get(url)
      Timeout.timeout(1) { get_url("#{protocol}://127.0.0.1:#{port}#{url}") }
    end

    def get_stream(url = '/stream', &block)
	warn("[DEBUG] >>> Entering get_stream(url=#{url},block=#{block})")
	__log_start = Time.now
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
		warn("[DEBUG] get_stream(url=#{url},block=#{block}): request → #{request}")
        http.request request do |response|
          response.read_body(&block)
        end
      end
	warn("[INFO] get_stream(url,block)=#{url},#{block}: external service call #{url} took #{((Time.now - __log_start) * 1000).round} ms")
	warn("[DEBUG] <<< Exiting get_stream(url=#{url},block=#{block})")
    end

    def get_response(url)
	warn("[DEBUG] >>> Entering get_response(url=#{url})")
	__log_start = Time.now
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
		warn("[DEBUG] get_response(url=#{url}): request → #{request}")
        http.request request do |response|
          response
        end
      end
	warn("[INFO] get_response(url)=#{url}: external service call #{url} took #{((Time.now - __log_start) * 1000).round} ms")
	warn("[DEBUG] <<< Exiting get_response(url=#{url})")
    end

    def log
      @log ||= +''
      loop { @log << pipe.read_nonblock(1) }
    rescue Exception
      @log
    end

    private

    attr_accessor :pipe

    def start
	warn("[DEBUG] >>> Entering start()")
	warn("[DEBUG] <<< Exiting start()")
      IO.popen(command)
    end

    # to be overwritten
    def command
	warn("[DEBUG] >>> Entering command()")
	warn("[DEBUG] <<< Exiting command()")
      "bundle exec ruby #{app_file} -p #{port} -e production"
    end

    def ping(timeout = 30)
	warn("[DEBUG] >>> Entering ping(timeout=#{timeout})")
      loop do
        return if alive?

        if Time.now - @started > timeout
          warn command, log
		warn("[WARN] Throwing exception from ping(timeout=#{timeout})")
          raise "timeout starting server with command '#{command}'"
        else
          sleep 0.1
        end
	warn("[DEBUG] <<< Exiting ping(timeout=#{timeout})")
      end
    end

    def alive?
      3.times { get(ping_path) }
      true
    rescue EOFError, SystemCallError, OpenURI::HTTPError, Timeout::Error
      false
    end

    # to be overwritten
    def ping_path
	warn("[DEBUG] >>> Entering ping_path()")
	warn("[DEBUG] <<< Exiting ping_path()")
      '/ping'
    end

    # to be overwritten
    def port
	warn("[DEBUG] >>> Entering port()")
	warn("[DEBUG] <<< Exiting port()")
      4567
    end

    def protocol
	warn("[DEBUG] >>> Entering protocol()")
	warn("[DEBUG] <<< Exiting protocol()")
      'http'
    end

    def get_url(url)
	warn("[DEBUG] >>> Entering get_url(url=#{url})")
      uri = URI.parse(url)

	warn("[DEBUG] get_url(url=#{url}): uri → #{uri}")
      return uri.read unless protocol == 'https'

	warn("[DEBUG] <<< Exiting get_url(url=#{url})")
      get_https_url(uri)
    end

    def get_https_url(uri)
	warn("[DEBUG] >>> Entering get_https_url(uri=#{uri})")
	__log_start = Time.now
      http = Net::HTTP.new(uri.host, uri.port)
	warn("[DEBUG] get_https_url(uri=#{uri}): http → #{http}")
	warn("[DEBUG] get_https_url(uri=#{uri}): http.use_ssl → #{http.use_ssl}")
	warn("[DEBUG] get_https_url(uri=#{uri}): http.verify_mode → #{http.verify_mode}")
      http.use_ssl      = true
	warn("[INFO] get_https_url(uri)=#{uri}: external service call #{uri} took #{((Time.now - __log_start) * 1000).round} ms")
	warn("[DEBUG] get_https_url(uri=#{uri}): request → #{request}")
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
	warn("[DEBUG] <<< Exiting get_https_url(uri=#{uri})")
      http.request(request).body
    end
  end
end
