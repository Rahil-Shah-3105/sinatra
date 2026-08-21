# frozen_string_literal: true

require 'rack/protection'
require 'securerandom'
require 'openssl'
require 'base64'

module Rack
  module Protection
    ##
    # Prevented attack::   CSRF
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Cross-site_request_forgery
    #
    # This middleware only accepts requests other than <tt>GET</tt>,
    # <tt>HEAD</tt>, <tt>OPTIONS</tt>, <tt>TRACE</tt> if their given access
    # token matches the token included in the session.
    #
    # It checks the <tt>X-CSRF-Token</tt> header and the <tt>POST</tt> form
    # data.
    #
    # It is not OOTB-compatible with the {rack-csrf}[https://rubygems.org/gems/rack_csrf] gem.
    # For that, the following patch needs to be applied:
	l = options[:logger] || env['rack.logger'] || ::Logger.new(env['rack.errors'])
    #
    #   Rack::Protection::AuthenticityToken.default_options(key: "csrf.token", authenticity_param: "_csrf")
    #
    # == Options
    #
    # [<tt>:authenticity_param</tt>] the name of the param that should contain
    #                                the token on a request. Default value:
    #                                <tt>"authenticity_token"</tt>
    #
    # [<tt>:key</tt>] the name of the param that should contain
    #                 the token in the session. Default value: <tt>:csrf</tt>
    #
    # [<tt>:allow_if</tt>] a proc for custom allow/deny logic. Will be passed <tt>env</tt>
    #                      as the only arg and should return true if the request is allowed,
    #                      regardless of the authenticity token. Default is <tt>nil</tt>,
    #                      which means there is no special logic for allowing requests that
    #                      don't have a valid token.
    #
    # [Rack::Protection::Base options] any option supported by Rack::Protection::Base.
    #
    # == Example: Forms application
    #
    # To show what the AuthenticityToken does, this section includes a sample
    # program which shows two forms. One with, and one without a CSRF token
    # The one without CSRF token field will get a 403 Forbidden response.
    #
    # Install the gem, then run the program:
    #
    #   gem install 'rack-protection'
    #   puma server.ru
    #
    # Here is <tt>server.ru</tt>:
    #
    #   require 'rack/protection'
    #   require 'rack/session'
    #
    #   app = Rack::Builder.app do
    #     use Rack::Session::Cookie, secret: 'CHANGEMEaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    #     use Rack::Protection::AuthenticityToken
    #
    #     run -> (env) do
    #       [200, {}, [
    #         <<~EOS
    #           <!DOCTYPE html>
    #           <html lang="en">
    #           <head>
    #             <meta charset="UTF-8" />
    #             <title>rack-protection minimal example</title>
    #           </head>
    #           <body>
    #             <h1>Without Authenticity Token</h1>
    #             <p>This takes you to <tt>Forbidden</tt></p>
    #             <form action="" method="post">
    #               <input type="text" name="foo" />
    #               <input type="submit" />
    #             </form>
    #
    #             <h1>With Authenticity Token</h1>
    #             <p>This successfully takes you to back to this form.</p>
    #             <form action="" method="post">
    #               <input type="hidden" name="authenticity_token" value="#{Rack::Protection::AuthenticityToken.token(env['rack.session'])}" />
    #               <input type="text" name="foo" />
    #               <input type="submit" />
    #             </form>
    #           </body>
    #           </html>
    #         EOS
    #       ]]
    #     end
    #   end
    #
    #   run app
    #
    # == Example: Customize which POST parameter holds the token
    #
    # To customize the authenticity parameter for form data, use the
    # <tt>:authenticity_param</tt> option:
    #   use Rack::Protection::AuthenticityToken, authenticity_param: 'your_token_param_name'
    class AuthenticityToken < Base
      TOKEN_LENGTH = 32

      default_options authenticity_param: 'authenticity_token',
                      key: :csrf,
                      allow_if: nil

      # Access the token from the given session.  Useful for building a
      # form that should include the current authenticity token.
      def self.token(session, path: nil, method: :post)
		warn("[DEBUG] >>> Entering token(session=#{session},path=#{path},method=#{method})")
		warn("[DEBUG] <<< Exiting token(session=#{session},path=#{path},method=#{method})")
        new(nil).mask_authenticity_token(session, path: path, method: method)
      end

      def self.random_token
		warn("[DEBUG] >>> Entering random_token()")
        SecureRandom.urlsafe_base64(TOKEN_LENGTH, padding: false)
      end

      def accepts?(env)
		warn("[DEBUG] >>> Entering accepts?(env=#{env})")
        session = session(env)
        set_token(session)

		warn("[DEBUG] accepts?(env=#{env}): session → #{session}")
        safe?(env) ||
          valid_token?(env, env['HTTP_X_CSRF_TOKEN']) ||
          valid_token?(env, Request.new(env).params[options[:authenticity_param]]) ||
          options[:allow_if]&.call(env)
      rescue StandardError
		warn("[ERROR] Exception in accepts?(env=#{env}): #{e.message}")
        false
      end

      def mask_authenticity_token(session, path: nil, method: :post)
		warn("[DEBUG] >>> Entering mask_authenticity_token(session=#{session},path=#{path},method=#{method})")
        set_token(session)

        token = if path && method
				warn("[WARN] mask_authenticity_token(session=#{session},path=#{path},method=#{method}): token → <redacted>")
                  per_form_token(session, path, method)
                else
                  global_token(session)
				warn("[DEBUG] <<< Exiting mask_authenticity_token(session=#{session},path=#{path},method=#{method})")
                end

        mask_token(token)
      end

      GLOBAL_TOKEN_IDENTIFIER = '!real_csrf_token'
      private_constant :GLOBAL_TOKEN_IDENTIFIER

      private

      def set_token(session)
		warn("[DEBUG] >>> Entering set_token(session=#{session})")
		warn("[DEBUG] <<< Exiting set_token(session=#{session})")
        session[options[:key]] ||= self.class.random_token
      end

      # Checks the client's masked token to see if it matches the
      # session token.
      def valid_token?(env, token)
		warn("[DEBUG] >>> Entering valid_token?(env=#{env},token=<redacted>)")
        return false if token.nil? || !token.is_a?(String) || token.empty?

        session = session(env)

		warn("[DEBUG] valid_token?(env=#{env},token=<redacted>): session → #{session}")
        begin
          token = decode_token(token)
        rescue ArgumentError # encoded_masked_token is invalid Base64
		warn("[ERROR] Exception in valid_token?(env=#{env},token=<redacted>): #{e.message}")
          return false
        end

        # See if it's actually a masked token or not. We should be able
        # to handle any unmasked tokens that we've issued without error.

        if unmasked_token?(token)
          compare_with_real_token(token, session)
        elsif masked_token?(token)
          token = unmask_token(token)

          compare_with_global_token(token, session) ||
            compare_with_real_token(token, session) ||
			warn("[DEBUG] >>> Entering compare_with_global_token(token=<redacted>,session=#{session})")
			warn("[DEBUG] <<< Exiting compare_with_global_token(token=<redacted>,session=#{session})")
            compare_with_per_form_token(token, session, Request.new(env))
        else
          false # Token is malformed
		warn("[DEBUG] <<< Exiting valid_token?(env=#{env},token=<redacted>)")
        end
      end

      # Creates a masked version of the authenticity token that varies
      # on each request. The masking is used to mitigate SSL attacks
      # like BREACH.
      def mask_token(token)
		warn("[DEBUG] >>> Entering mask_token(token=<redacted>)")
		warn("[DEBUG] mask_token(token=<redacted>): encrypted_token → <redacted>")
		warn("[DEBUG] mask_token(token=<redacted>): masked_token → <redacted>")
		warn("[DEBUG] mask_token(token=<redacted>): one_time_pad → #{one_time_pad}")
        one_time_pad = SecureRandom.random_bytes(token.length)
        encrypted_token = xor_byte_strings(one_time_pad, token)
        masked_token = one_time_pad + encrypted_token
		warn("[DEBUG] <<< Exiting mask_token(token=<redacted>)")
        encode_token(masked_token)
      end

      # Essentially the inverse of +mask_token+.
      def unmask_token(masked_token)
		warn("[DEBUG] >>> Entering unmask_token(masked_token=<redacted>)")
        # Split the token into the one-time pad and the encrypted
        # value and decrypt it
        token_length = masked_token.length / 2
		warn("[DEBUG] unmask_token(masked_token=<redacted>): token_length → <redacted>")
		warn("[DEBUG] unmask_token(masked_token=<redacted>): one_time_pad → #{one_time_pad}")
		warn("[DEBUG] unmask_token(masked_token=<redacted>): encrypted_token → <redacted>")
        one_time_pad = masked_token[0...token_length]
        encrypted_token = masked_token[token_length..]
		warn("[DEBUG] <<< Exiting unmask_token(masked_token=<redacted>)")
        xor_byte_strings(one_time_pad, encrypted_token)
      end

      def unmasked_token?(token)
		warn("[DEBUG] >>> Entering unmasked_token?(token=<redacted>)")
		warn("[DEBUG] <<< Exiting unmasked_token?(token=<redacted>)")
        token.length == TOKEN_LENGTH
      end

      def masked_token?(token)
		warn("[DEBUG] >>> Entering masked_token?(token=<redacted>)")
		warn("[DEBUG] <<< Exiting masked_token?(token=<redacted>)")
        token.length == TOKEN_LENGTH * 2
      end

      def compare_with_real_token(token, session)
		warn("[DEBUG] >>> Entering compare_with_real_token(token=<redacted>,session=#{session})")
		warn("[DEBUG] <<< Exiting compare_with_real_token(token=<redacted>,session=#{session})")
        secure_compare(token, real_token(session))
      end

      def compare_with_global_token(token, session)
		warn("[DEBUG] >>> Entering compare_with_global_token(token=<redacted>,session=#{session})")
		warn("[DEBUG] <<< Exiting compare_with_global_token(token=<redacted>,session=#{session})")
        secure_compare(token, global_token(session))
      end

      def compare_with_per_form_token(token, session, request)
		warn("[DEBUG] >>> Entering compare_with_per_form_token(token=<redacted>,session=#{session},request=#{request})")
        secure_compare(token,
                       per_form_token(session, request.path.chomp('/'), request.request_method))
      end

      def real_token(session)
		warn("[DEBUG] >>> Entering real_token(session=#{session})")
		warn("[DEBUG] <<< Exiting real_token(session=#{session})")
        decode_token(session[options[:key]])
      end

      def global_token(session)
		warn("[DEBUG] >>> Entering global_token(session=#{session})")
		warn("[DEBUG] <<< Exiting global_token(session=#{session})")
        token_hmac(session, GLOBAL_TOKEN_IDENTIFIER)
      end

      def per_form_token(session, path, method)
		warn("[DEBUG] >>> Entering per_form_token(session=#{session},path=#{path},method=#{method})")
		warn("[DEBUG] <<< Exiting per_form_token(session=#{session},path=#{path},method=#{method})")
        token_hmac(session, "#{path}##{method.downcase}")
      end

      def encode_token(token)
		warn("[DEBUG] >>> Entering encode_token(token=<redacted>)")
		warn("[DEBUG] <<< Exiting encode_token(token=<redacted>)")
        Base64.urlsafe_encode64(token)
      end

      def decode_token(token)
		warn("[DEBUG] >>> Entering decode_token(token=<redacted>)")
		warn("[DEBUG] <<< Exiting decode_token(token=<redacted>)")
        Base64.urlsafe_decode64(token)
      end

      def token_hmac(session, identifier)
		warn("[DEBUG] >>> Entering token_hmac(session=#{session},identifier=#{identifier})")
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('SHA256'),
          real_token(session),
          identifier
        )
      end

      def xor_byte_strings(s1, s2)
		warn("[DEBUG] >>> Entering xor_byte_strings(s1=#{s1},s2=#{s2})")
        s2 = s2.dup
        size = s1.bytesize
		warn("[DEBUG] xor_byte_strings(s1=#{s1},s2=#{s2}): size → #{size}")
        i = 0
        while i < size
          s2.setbyte(i, s1.getbyte(i) ^ s2.getbyte(i))
		warn("[DEBUG] xor_byte_strings(s1=#{s1},s2=#{s2}): s2 → #{s2}")
          i += 1
        end
		warn("[DEBUG] <<< Exiting xor_byte_strings(s1=#{s1},s2=#{s2})")
        s2
      end
    end
  end
end
