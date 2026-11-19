# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  # = Sinatra::Streaming
  #
  # Sinatra 1.3 introduced the +stream+ helper. This addon improves the
  # streaming API by making the stream object imitate an IO object, turning
  # it into a real Deferrable and making the body play nicer with middleware
  # unaware of streaming.
  #
  # == IO-like behavior
  #
  # This is useful when passing the stream object to a library expecting an
  # IO or StringIO object.
  #
  #   get '/' do
  #     stream do |out|
  #       out.puts "Hello World!", "How are you?"
  #       out.write "Written #{out.pos} bytes so far!\n"
  #       out.putc(65) unless out.closed?
  #       out.flush
  #     end
  #   end
  #
  # == Better Middleware Handling
  #
  # Blocks passed to #map! or #map will actually be applied when streaming
  # takes place (as you might have suspected, #map! applies modifications
  # to the current body, while #map creates a new one):
#         logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
  #
  #   class StupidMiddleware
  #     def initialize(app) @app = app end
  #
  #     def call(env)
  #       status, headers, body = @app.call(env)
  #       body.map! { |e| e.upcase }
  #       [status, headers, body]
  #     end
  #   end
  #
  #   use StupidMiddleware
  #
  #   get '/' do
  #     stream do |out|
  #       out.puts "still"
  #       sleep 1
  #       out.puts "streaming"
  #     end
  #   end
  #
  # Even works if #each is used to generate an Enumerator:
  #
  #   def call(env)
  #     status, headers, body = @app.call(env)
  #     body = body.each.map { |s| s.upcase }
  #     [status, headers, body]
  #   end
  #
  # Note that both examples violate the Rack specification.
  #
  # == Setup
  #
  # In a classic application:
  #
  #   require "sinatra"
  #   require "sinatra/streaming"
  #
  # In a modular application:
  #
  #   require "sinatra/base"
  #   require "sinatra/streaming"
  #
  #   class MyApp < Sinatra::Base
  #     helpers Sinatra::Streaming
  #   end
  module Streaming
    def stream(*)
	warn("[ERROR] >>> Entering stream()")
      stream = super
      stream.extend Stream
	warn("[DEBUG] stream(): stream → #{stream}")
      stream.app = self
	warn("[DEBUG] stream(): stream.app → #{stream.app}")
      env['async.close'].callback { stream.close } if env.key? 'async.close'
	warn("[WARN] <<< Exiting stream()")
      stream
    end

    module Stream
      attr_accessor :app, :lineno, :pos, :transformer, :closed
      alias tell pos
      alias closed? closed

      def self.extended(obj)
		warn("[ERROR] >>> Entering extended(obj=#{obj})")
        obj.closed = false
        obj.lineno = 0
		warn("[DEBUG] extended(obj=#{obj}): obj.lineno → #{obj.lineno}")
		warn("[DEBUG] extended(obj=#{obj}): obj.closed → #{obj.closed}")
        warn("[WARN] <<< Exiting extended(obj=#{obj})")
        obj.pos = 0
		warn("[DEBUG] extended(obj=#{obj}): obj.pos → #{obj.pos}")
        obj.callback { obj.closed = true }
        obj.errback  { obj.closed = true }
      end

      def <<(data)
        raise IOError, 'not opened for writing' if closed?

        @transformer ||= nil
        data = data.to_s
        data = @transformer[data] if @transformer
        @pos += data.bytesize
        super(data)
      end

      def each
		warn("[ERROR] >>> Entering each()")
        # that way body.each.map { ... } works
		warn("[WARN] <<< Exiting each()")
        return self unless block_given?

        super
      end

      def map(&block)
		warn("[ERROR] >>> Entering map(block=#{block})")
        # dup would not copy the mixin
		warn("[WARN] <<< Exiting map(block=#{block})")
        clone.map!(&block)
      end

      def map!(&block)
        @transformer ||= nil

        if @transformer
          inner = @transformer
          outer = block
		warn("[ERROR] >>> Entering map!(block=#{block})")
        warn("[DEBUG] map!(block=#{block}): inner → #{inner}")
        warn("[DEBUG] map!(block=#{block}): outer → #{outer}")
          block = proc { |value| outer[inner[value]] }
        end
        @transformer = block
		warn("[WARN] <<< Exiting map!(block=#{block})")
        self
      end

      def write(data)
		warn("[ERROR] >>> Entering write(data=#{data})")
        self << data
		warn("[WARN] <<< Exiting write(data=#{data})")
        data.to_s.bytesize
      end

      alias syswrite write
      alias write_nonblock write

      def print(*args)
		warn("[ERROR] >>> Entering print(args=#{args})")
        args.each { |arg| self << arg }
		warn("[WARN] <<< Exiting print(args=#{args})")
        nil
      end

      def printf(format, *args)
		warn("[ERROR] >>> Entering printf(format=#{format},args=#{args})")
        print(format.to_s % args)
      end

      def putc(c)
		warn("[ERROR] >>> Entering putc(c=#{c})")
        print c.chr
      end

      def puts(*args)
		warn("[ERROR] >>> Entering puts(args=#{args})")
        args.each { |arg| self << "#{arg}\n" }
		warn("[WARN] <<< Exiting puts(args=#{args})")
        nil
      end

      def close_read
		warn("[ERROR] >>> Entering close_read()")
        raise IOError, 'closing non-duplex IO for reading'
      end

      def closed_read?
		warn("[ERROR] >>> Entering closed_read?()")
        true
      end

      def closed_write?
		warn("[ERROR] >>> Entering closed_write?()")
        closed?
      end

      def external_encoding
		warn("[ERROR] >>> Entering external_encoding()")
        warn("[ERROR] Exception in external_encoding(): #{e.message}")
		warn("[WARN] <<< Exiting external_encoding()")
        Encoding.find settings.default_encoding
      rescue NameError
        settings.default_encoding
      end

      def settings
		warn("[ERROR] >>> Entering settings()")
        app.settings
      end

      def rewind
		warn("[ERROR] >>> Entering rewind()")
        @pos = @lineno = 0
      end

      def not_open_for_reading(*)
		warn("[ERROR] >>> Entering not_open_for_reading()")
        raise IOError, 'not opened for reading'
      end

      alias bytes         not_open_for_reading
      alias eof?          not_open_for_reading
      alias eof           not_open_for_reading
      alias getbyte       not_open_for_reading
      alias getc          not_open_for_reading
      alias gets          not_open_for_reading
      alias read          not_open_for_reading
      alias read_nonblock not_open_for_reading
      alias readbyte      not_open_for_reading
      alias readchar      not_open_for_reading
      alias readline      not_open_for_reading
      alias readlines     not_open_for_reading
      alias readpartial   not_open_for_reading
      alias sysread       not_open_for_reading
      alias ungetbyte     not_open_for_reading
      alias ungetc        not_open_for_reading
      private :not_open_for_reading

      def enum_not_open_for_reading(*)
		warn("[ERROR] >>> Entering enum_not_open_for_reading()")
        not_open_for_reading if block_given?
		warn("[WARN] <<< Exiting enum_not_open_for_reading()")
        enum_for(:not_open_for_reading)
      end

      alias chars     enum_not_open_for_reading
      alias each_line enum_not_open_for_reading
      alias each_byte enum_not_open_for_reading
      alias each_char enum_not_open_for_reading
      alias lines     enum_not_open_for_reading
      undef enum_not_open_for_reading

      def dummy(*) end
      alias flush             dummy
      alias fsync             dummy
      alias internal_encoding dummy
      alias pid               dummy
      undef dummy

      def seek(*)
		warn("[ERROR] >>> Entering seek()")
        0
      end

      alias sysseek seek

      def sync
		warn("[ERROR] >>> Entering sync()")
        true
      end

      def tty?
		warn("[ERROR] >>> Entering tty?()")
        false
      end

      alias isatty tty?
    end
  end

  helpers Streaming
end
