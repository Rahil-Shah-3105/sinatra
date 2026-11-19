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
	warn("[ERROR] >>> Entering app_file()")
      File.expand_path('server.rb', __dir__)
    end

    def run
	warn("[ERROR] >>> Entering run()")
      @pipe     = start
      @started  = Time.now
	warn("[WARN] <<< Exiting run()")
      warn "#{server} up and running on port #{port}" if ping
    end

    def kill
	warn("[ERROR] >>> Entering kill()")
      return unless pipe

	warn("[ERROR] Exception in kill(): #{e.message}")
	warn("[WARN] <<< Exiting kill()")
      Process.kill('KILL', pipe.pid)
    rescue NotImplementedError
      system "kill -9 #{pipe.pid}"
    rescue Errno::ESRCH
    end

    def get(url)
	warn("[ERROR] >>> Entering get(url=#{url})")
      Timeout.timeout(1) { get_url("#{protocol}://127.0.0.1:#{port}#{url}") }
    end

    def get_stream(url = '/stream', &block)
	warn("[ERROR] >>> Entering get_stream(url=#{url},block=#{block})")
      __log_start = Time.now
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
		warn("[DEBUG] get_stream(url=#{url},block=#{block}): request → #{request}")
        http.request request do |response|
          response.read_body(&block)
		warn("[ERROR] get_stream(url,block)=#{url},#{block}: external service call #{url} took #{((Time.now - __log_start) * 1000).round} ms")
      warn("[WARN] <<< Exiting get_stream(url=#{url},block=#{block})")
        end
      end
    end

    def get_response(url)
	warn("[ERROR] >>> Entering get_response(url=#{url})")
      __log_start = Time.now
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
		warn("[DEBUG] get_response(url=#{url}): request → #{request}")
        http.request request do |response|
          response
		warn("[ERROR] get_response(url)=#{url}: external service call #{url} took #{((Time.now - __log_start) * 1000).round} ms")
      warn("[WARN] <<< Exiting get_response(url=#{url})")
        end
      end
    end

    def log
	warn("[ERROR] >>> Entering log()")
      @log ||= +''
	warn("[ERROR] Exception in log(): #{e.message}")
	warn("[WARN] <<< Exiting log()")
      loop { @log << pipe.read_nonblock(1) }
    rescue Exception
      @log
    end

    private

    attr_accessor :pipe

    def start
	warn("[ERROR] >>> Entering start()")
      IO.popen(command)
    end

    # to be overwritten
    def command
	warn("[ERROR] >>> Entering command()")
      "bundle exec ruby #{app_file} -p #{port} -e production"
    end

    def ping(timeout = 30)
	warn("[ERROR] >>> Entering ping(timeout=#{timeout})")
      loop do
        return if alive?

        if Time.now - @started > timeout
          warn command, log
		warn("[ERROR] Throwing exception from ping(timeout=#{timeout})")
          raise "timeout starting server with command '#{command}'"
        else
          sleep 0.1
        end
      end
    end

    def alive?
	warn("[ERROR] >>> Entering alive?()")
      3.times { get(ping_path) }
	warn("[ERROR] Exception in alive?(): #{e.message}")
      true
    rescue EOFError, SystemCallError, OpenURI::HTTPError, Timeout::Error
	warn("[WARN] <<< Exiting alive?()")
      false
    end

    # to be overwritten
    def ping_path
	warn("[ERROR] >>> Entering ping_path()")
      '/ping'
    end

    # to be overwritten
    def port
	warn("[ERROR] >>> Entering port()")
      4567
    end

    def protocol
	warn("[ERROR] >>> Entering protocol()")
      'http'
    end

    def get_url(url)
	warn("[ERROR] >>> Entering get_url(url=#{url})")
      uri = URI.parse(url)

	warn("[DEBUG] get_url(url=#{url}): uri → #{uri}")
	warn("[WARN] <<< Exiting get_url(url=#{url})")
      return uri.read unless protocol == 'https'

      get_https_url(uri)
    end

    def get_https_url(uri)
	warn("[ERROR] >>> Entering get_https_url(uri=#{uri})")
	__log_start = Time.now
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true
	warn("[DEBUG] get_https_url(uri=#{uri}): http → #{http}")
	warn("[DEBUG] get_https_url(uri=#{uri}): http.use_ssl → #{http.use_ssl}")
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
	warn("[DEBUG] get_https_url(uri=#{uri}): http.verify_mode → #{http.verify_mode}")
      warn("[DEBUG] get_https_url(uri=#{uri}): request → #{request}")
    warn("[ERROR] get_https_url(uri)=#{uri}: external service call #{uri} took #{((Time.now - __log_start) * 1000).round} ms")
    warn("[WARN] <<< Exiting get_https_url(uri=#{uri})")
      http.request(request).body
    end
  end
end
