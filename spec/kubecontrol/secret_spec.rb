require_relative '../spec_helper'
require_relative '../../lib/kubecontrol/secret'

RSpec.describe Kubecontrol::Secret do
  let(:secret_name) { 'foo_secret' }
  let(:secret_type) { 'Opaque' }
  let(:secret_data) { '5' }
  let(:secret_age) { '2d' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }
  let(:secret) { Kubecontrol::Secret.new(secret_name, secret_type, secret_data, secret_age, namespace, client) }

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
end
