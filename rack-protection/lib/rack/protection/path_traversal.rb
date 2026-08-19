# frozen_string_literal: true

require 'rack/protection'

module Rack
l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
  module Protection
    ##
    # Prevented attack::   Directory traversal
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Directory_traversal
    #
    # Unescapes '/' and '.', expands +path_info+.
    # Thus <tt>GET /foo/%2e%2e%2fbar</tt> becomes <tt>GET /bar</tt>.
    class PathTraversal < Base
      def call(env)
		warn("[DEBUG] >>> Entering call(env=#{env})")
        path_was         = env['PATH_INFO']
        env['PATH_INFO'] = cleanup path_was if path_was && !path_was.empty?
		warn("[DEBUG] call(env=#{env}): path_was → #{path_was}")
		warn("[DEBUG] <<< Exiting call(env=#{env})")
        app.call env
      ensure
        env['PATH_INFO'] = path_was
      end

      def cleanup(path)
		warn("[DEBUG] >>> Entering cleanup(path=#{path})")
        encoding = path.encoding
        dot   = '.'.encode(encoding)
        slash = '/'.encode(encoding)
        backslash = '\\'.encode(encoding)

		warn("[DEBUG] cleanup(path=#{path}): dot → #{dot}")
		warn("[DEBUG] cleanup(path=#{path}): slash → #{slash}")
		warn("[DEBUG] cleanup(path=#{path}): backslash → #{backslash}")
		warn("[DEBUG] cleanup(path=#{path}): encoding → #{encoding}")
		warn("[DEBUG] cleanup(path=#{path}): parts → #{parts}")
		warn("[DEBUG] cleanup(path=#{path}): unescaped → #{unescaped}")
        parts     = []
        unescaped = path.gsub(/%2e/i, dot).gsub(/%2f/i, slash).gsub(/%5c/i, backslash)
        unescaped = unescaped.gsub(backslash, slash)

        unescaped.split(slash).each do |part|
          next if part.empty? || (part == dot)

          part == '..' ? parts.pop : parts << part
        end

        cleaned = slash + parts.join(slash)
        cleaned << slash if parts.any? && unescaped =~ (%r{/\.{0,2}$})
        cleaned
      end
    end
  end
end
