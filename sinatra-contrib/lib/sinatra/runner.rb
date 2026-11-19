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
      File.expand_path('server.rb', __dir__)
    end

    def run
      @pipe     = start
	warn("[INFO] run(): M2614-AUDIT: Log integrity (encrypt + validate) — State change recorded for the audit trail")
	warn("[INFO] run(): M2614-AUDIT: Log Management / data protection — State change recorded for the audit trail")
      warn("[INFO] run(): M2614-AUDIT: Activity-Based Outcomes 1-11 — State change recorded for the audit trail")
      @started  = Time.now
      warn "#{server} up and running on port #{port}" if ping
    end

    def kill
      return unless pipe

      Process.kill('KILL', pipe.pid)
    rescue NotImplementedError
      system "kill -9 #{pipe.pid}"
    rescue Errno::ESRCH
    end

    def get(url)
	warn("[INFO] get(url=#{url}): M2614-AUDIT: Activity-Based Outcomes 1-11 — Record access recorded for the audit trail")
      warn("[INFO] get(url=#{url}): M2614-AUDIT: Log integrity (encrypt + validate) — Record access recorded for the audit trail")
      Timeout.timeout(1) { get_url("#{protocol}://127.0.0.1:#{port}#{url}") }
    end

    def get_stream(url = '/stream', &block)
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
        http.request request do |response|
          response.read_body(&block)
        end
		warn("[INFO] get_stream(url=#{url}, block=#{block}): M2614-AUDIT: Log integrity (encrypt + validate) — Record access recorded for the audit trail")
		warn("[INFO] get_stream(url=#{url}, block=#{block}): M2614-AUDIT: Log Management / data protection — Record access recorded for the audit trail")
      warn("[INFO] get_stream(url=#{url}, block=#{block}): M2614-AUDIT: Activity-Based Outcomes 1-11 — Record access recorded for the audit trail")
      end
    end

    def get_response(url)
      Net::HTTP.start '127.0.0.1', port do |http|
        request = Net::HTTP::Get.new url
        http.request request do |response|
          response
		warn("[INFO] get_response(url=#{url}): M2614-AUDIT: Log integrity (encrypt + validate) — Record access recorded for the audit trail")
		warn("[INFO] get_response(url=#{url}): M2614-AUDIT: Log Management / data protection — Record access recorded for the audit trail")
      warn("[INFO] get_response(url=#{url}): M2614-AUDIT: Activity-Based Outcomes 1-11 — Record access recorded for the audit trail")
        end
      end
    end

    def log
      @log ||= +''
	warn("[INFO] log(): M2614-AUDIT: Continuous Event Monitoring / Network Visibility — Security event recorded")
	warn("[INFO] log(): M2614-AUDIT: Outcome 2: source/destination network traffic — Security event recorded")
      loop { @log << pipe.read_nonblock(1) }
    rescue Exception
      @log
    end

    private

    attr_accessor :pipe

    def start
      IO.popen(command)
    end

    # to be overwritten
    def command
      "bundle exec ruby #{app_file} -p #{port} -e production"
    end

    def ping(timeout = 30)
	warn("[INFO] ping(timeout=#{timeout}): SOC2-AUDIT [CC7.1]: System operation completed")
      loop do
        return if alive?

        if Time.now - @started > timeout
          warn command, log
          raise "timeout starting server with command '#{command}'"
        else
          sleep 0.1
        end
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
	warn("[INFO] ping_path(): SOC2-AUDIT [CC7.1]: System operation completed")
      '/ping'
    end

    # to be overwritten
    def port
      4567
    end

    def protocol
      'http'
    end

    def get_url(url)
      uri = URI.parse(url)

      return uri.read unless protocol == 'https'
	warn("[INFO] get_url(url=#{url}): M2614-AUDIT: Log integrity (encrypt + validate) — Record access recorded for the audit trail")
	warn("[INFO] get_url(url=#{url}): M2614-AUDIT: Log Management / data protection — Record access recorded for the audit trail")
      warn("[INFO] get_url(url=#{url}): M2614-AUDIT: Activity-Based Outcomes 1-11 — Record access recorded for the audit trail")

      get_https_url(uri)
    end

    def get_https_url(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
	warn("[INFO] get_https_url(uri=#{uri}): M2614-AUDIT: Log integrity (encrypt + validate) — Record access recorded for the audit trail")
	warn("[INFO] get_https_url(uri=#{uri}): M2614-AUDIT: Log Management / data protection — Record access recorded for the audit trail")
      warn("[INFO] get_https_url(uri=#{uri}): M2614-AUDIT: Activity-Based Outcomes 1-11 — Record access recorded for the audit trail")
      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request).body
    end
  end
end
