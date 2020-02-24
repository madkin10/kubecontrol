require_relative '../../spec_helper'
require_relative '../../../lib/kubecontrol/resources/stateful_set'

RSpec.describe Kubecontrol::Resources::StatefulSet do
  let(:stateful_set_name) { 'foo_stateful_set' }
  let(:stateful_set_age) { '2d' }
  let(:stateful_set_ready) { '1/1' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }
  let(:stateful_set) { Kubecontrol::Resources::StatefulSet.new(stateful_set_name, stateful_set_ready, stateful_set_age, namespace, client) }

  describe '#initialize' do
    subject { stateful_set }

    it 'sets the stateful_set name field' do
      expect(subject.name).to eq stateful_set_name
    end

    it 'sets the stateful_set age field' do
      expect(subject.age).to eq stateful_set_age
    end

    it 'sets the stateful_set ready field' do
      expect(subject.ready).to eq stateful_set_ready
    end

    it 'sets the stateful_set namespace' do
      expect(subject.namespace).to eq namespace
    end

    it 'sets the client' do
      expect(subject.client).to eq client
    end
  end

  describe '#ready?' do
    subject { stateful_set.ready? }

    context 'all replicas running' do
      let(:stateful_set_ready) { '3/3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not running' do
      let(:stateful_set_ready) { '2/3' }

      it { is_expected.to eq true }
    end

    context 'no replicas running' do
      let(:stateful_set_ready) { '0/3' }

      it { is_expected.to eq false }
    end
  end

  describe '#all_ready?' do
    subject { stateful_set.all_ready? }

    context 'all replicas running' do
      let(:stateful_set_ready) { '3/3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not running' do
      let(:stateful_set_ready) { '2/3' }

      it { is_expected.to eq false }
    end

    context 'no replicas running' do
      let(:stateful_set_ready) { '0/3' }

      it { is_expected.to eq false }
    end
  end

  describe '#scale' do
    let(:scale_count) { '5' }

    let(:kubectl_command) { "scale statefulset #{stateful_set_name} --replicas=#{scale_count}" }
    let(:std_out) { "stateful_set.extensions/#{stateful_set_name} scaled" }
    let(:std_err) { '' }
    let(:status_code) { 0 }
    let(:kubectl_command_response) { [std_out, std_err, status_code] }

    subject { stateful_set.scale(scale_count) }

    it 'sends the scale command via Kubecontrol::Client#kubectl_command' do
      expect(stateful_set.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      subject
    end

    it 'returns an array of std_out, std_err, and status code' do
      allow(stateful_set.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      std_out_response, std_err_response, status_code_response = subject
      expect(std_out_response).to eq std_out
      expect(std_err_response).to eq std_err
      expect(status_code_response).to eq status_code
    end
  end
end
