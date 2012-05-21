require 'spec_helper'

module AWS
  describe URL do

    before do
      @base_url = 'http://example.com/path'
      @url = URL.new @base_url, 'key', 'secret'
    end

    it 'requires a key' do
      expect {
        URL.new 'foo', nil, 'secret'
      }.to raise_error MissingKey
    end

    it 'requires a secret' do
      expect {
        URL.new 'foo', 'key', nil
      }.to raise_error MissingSecret
    end

    describe '#build' do
      subject { @url.build :get }

      it 'includes the base URL' do
        should { include @base_url }
      end

      it 'is signed' do
        should { match /Signature=[^&]+$/ }
      end
    end

    describe '#params' do
      subject { @url.params }

      it 'includes a key' do
        should { include 'AWSAccessKeyId' }
      end

      it 'includes a signature version' do
        should { include 'SignatureVersion' }
      end

      it 'includes a signature method' do
        should { include 'SignatureMethod' }
      end

      it 'includes a timestamp' do
        should { include 'Timestamp' }
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
    end
  end
end
