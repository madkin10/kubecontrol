require_relative '../../spec_helper'
require_relative '../../../lib/kubecontrol/resources/secret'

RSpec.describe Kubecontrol::Resources::Secret do
  let(:secret_name) { 'foo_secret' }
  let(:secret_type) { 'Opaque' }
  let(:secret_data) { '5' }
  let(:secret_age) { '2d' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }
  let(:secret) { Kubecontrol::Resources::Secret.new(secret_name, secret_type, secret_data, secret_age, namespace, client) }

  describe '#initialize' do
    subject { secret }

    it 'sets the secret name field' do
      expect(subject.name).to eq secret_name
    end

    it 'sets the secret type field' do
      expect(subject.type).to eq secret_type
    end

    it 'sets the secret data field' do
      expect(subject.data).to eq secret_data
    end

    it 'sets the secret age field' do
      expect(subject.age).to eq secret_age
    end

    it 'sets the secret namespace' do
      expect(subject.namespace).to eq namespace
    end

    it 'sets the client' do
      expect(subject.client).to eq client
    end
  end

  describe '#data_values' do
    let(:status_code) { 0 }
    let(:key_one) { 'one' }
    let(:value_one) { 'foo' }
    let(:key_two) { 'two' }
    let(:value_two) { 'bar' }
    let(:get_secret_std_out) do
      {
        data: {
          key_one => Base64.encode64(value_one),
          key_two => Base64.encode64(value_two),
        }
      }.to_json
    end
    let(:get_secret_response) { [get_secret_std_out, '', status_code] }

    subject { secret.data_values }

    before do
      allow(secret.client).to receive(:kubectl_command).with("get secret #{secret.name} -o json").and_return get_secret_response
    end

    it 'sends a kubectl request to the command line' do
      expect(secret.client).to receive(:kubectl_command).with("get secret #{secret.name} -o json").and_return get_secret_response
      subject
    end

    context 'kubectl command is successful' do
      it 'returns an hash of the decoded secret data' do
        result = subject
        expect(result).to be_an_instance_of Hash
        expect(result[key_one]).to eq(value_one)
        expect(result[key_two]).to eq(value_two)
      end
    end

    context 'kubectl command is unsuccessful' do
      let(:status_code) { 1 }
      it 'returns an empty hash' do
        expect(subject).to eq({})
      end
    end
  end
end
