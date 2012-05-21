require 'base64'
require 'openssl'
require 'time'
require 'uri'

module AWS
  # A Signed Amazon Web Services (AWS) URL.
  #
  # Currently supports Signature Version 2.
  #
  # Note to self: Do not touch this code unless you have a compelling reason.
  class URL
    # The SHA256 hash algorithm.
    SHA256 = OpenSSL::Digest::SHA256.new

    # Initializes a new URL.
    #
    # base_url - The String base URL, including scheme, host and path, of the
    #            AWS endpoint.
    # key      - The String AWS access key id.
    # secret   - The String AWS secret key.
    def initialize(base_url, key, secret)
      @base_url = URI base_url
      @key      = key
      @secret   = secret
      @params   = {}
    end

    # Builds a signed URL for specified HTTP method.
    #
    # method - A String-like HTTP method.
    #
    # Returns a String URL.
    def build(method)
      # Build an unsigned query string.
      query = params.sort.map { |k, v| "#{k}=#{ percent_encode v }" }.join '&'

      # Build the signature.
      string_to_sign = [
        method.to_s.upcase,
        @base_url.host,
        @base_url.path,
        query
      ].join "\n"
      signature = sign string_to_sign

      "#{@base_url}?#{query}&Signature=#{percent_encode signature}"
    end

    # Returns the Hash AWS parameters.
    def params
      required_params.merge @params
    end

    # Updates the AWS parameters.
    #
    # hash - A Hash.
    #
    # Returns nothing.
    def update(hash)
      hash.each do |key, val|
        # Syntactic sugar: Camelize symbol keys.
        if key.is_a? Symbol
          key = key.to_s.split('_').map(&:capitalize).join
        end

        @params[key] = val
      end
    end

    private

    def percent_encode(value)
      value.to_s.gsub(/([^\w.~-]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    def required_params
      {
        'AWSAccessKeyId'   => @key,
        'SignatureVersion' => '2',
        'SignatureMethod'  => 'HmacSHA256',
        'Timestamp'        => Time.now.utc.iso8601
      }
    end

    def sign(message)
      digest = OpenSSL::HMAC.digest SHA256, @secret, message
      Base64.encode64(digest).chomp
    end
  end
end
