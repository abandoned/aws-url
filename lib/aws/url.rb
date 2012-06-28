# Standard library dependencies.
require 'base64'
require 'openssl'
require 'time'
require 'uri'

# Internal dependencies.
require 'aws/url/signature'

module AWS
  # A Signed Amazon Web Services (AWS) URL.
  #
  # Supports Signature Version 2.
  class URL
    UNRESERVED = /([^\w.~-]+)/

    # Initializes a new URL.
    #
    # base_url - The String base URL, including scheme, host and path, of the
    #            AWS endpoint.
    # action   - The String-like HTTP action.
    # key      - The String AWS access key id.
    # secret   - The String AWS secret key.
    def initialize(base_url, action, key, secret)
      @base_url = URI base_url
      @action   = action.to_s.upcase
      @key      = key
      @secret   = secret
      @params   = {}
    end

    # Returns the Hash AWS parameters.
    def params
      default_params.merge @params
    end

    # Returns the signed query String.
    def query
      "#{unsigned_query}&Signature=#{escape signature}"
    end

    # Returns the signed URL String.
    def to_s
      "#{@base_url}?#{query}"
    end

    # Updates the AWS parameters.
    #
    # hash - A Hash.
    #
    # Returns self.
    def update(hash)
      @unsigned_query = nil

      hash.each do |key, val|
        # Syntactic sugar: Camelize symbol keys.
        if key.is_a? Symbol
          key = key.to_s.split('_').map(&:capitalize).join
        end
        @params[key] = val
      end

      self
    end

    private

    def default_params
      {
        'AWSAccessKeyId'   => @key,
        'SignatureVersion' => '2',
        'SignatureMethod'  => 'HmacSHA256',
        'Timestamp'        => Time.now.utc.iso8601
      }
    end

    def escape(value)
      value.to_s.gsub(UNRESERVED) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    def signature
      Signature.build @secret, string_to_sign
    end

    def string_to_sign
      [
        @action,
        @base_url.host,
        @base_url.path,
        unsigned_query
      ].join "\n"
    end

    def unsigned_query
      @unsigned_query ||=
        params.map { |k, v| "#{k}=#{ escape v }" }.sort.join '&'
    end
  end
end
