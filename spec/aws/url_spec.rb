require 'spec_helper'

module AWS
  describe URL do
    before do
      @base_url = 'http://example.com/path'
      @url = URL.new @base_url, :get, 'key', 'secret'
    end

    describe '#params' do
      subject { @url.params }

      it 'includes a key' do
        should include 'AWSAccessKeyId'
      end

      it 'includes a signature version' do
        should include 'SignatureVersion'
      end

      it 'includes a signature method' do
        should include 'SignatureMethod'
      end

      it 'includes a timestamp' do
        should include 'Timestamp'
      end
    end

    describe '#query' do
      subject { @url.query }

      it 'is signed' do
        should match /Signature=[^&]+$/
      end
    end

    describe '#to_s' do
      subject { @url.to_s }

      it 'includes the base URL' do
        should include @base_url
      end

      it 'includes the signed query' do
        should include @url.query
      end
    end

    describe '#update' do
      it 'updates the parameters' do
        @url.update 'Foo' => 'bar'
        @url.params.should include 'Foo'
      end

      it 'camelizes symbol keys' do
        @url.update :foo => 'bar'
        @url.params.should include 'Foo'
      end

      it 'returns self' do
        @url.update({}).should be @url
      end
    end
  end
end
