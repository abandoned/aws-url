module AWS
  class URL
    # Internal: A signature builder.
    class Signature
      SHA256 = OpenSSL::Digest::SHA256.new

      # Builds a signature.
      #
      # secret  - A String AWS secret key.
      # message - The String to sign.
      #
      # Returns a String signature.
      def self.build(secret, message)
        new(secret, message).build
      end

      def initialize(secret, message)
        @secret  = secret
        @message = message
      end

      def build
        Base64.encode64(digest).chomp
      end

      def digest
        OpenSSL::HMAC.digest SHA256, @secret, @message
      end
    end
  end
end
