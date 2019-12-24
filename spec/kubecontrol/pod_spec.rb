require_relative '../spec_helper'

RSpec.describe Kubecontrol::Pod do
  let(:pod_name) { 'foo_pod' }
  let(:pod_ready) { '1/1' }
  let(:pod_status) { 'Running' }
  let(:pod_restarts) { '0' }
  let(:pod_age) { '20d' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }

  describe '#initialize' do
    subject { Kubecontrol::Pod.new(pod_name, pod_ready, pod_status, pod_restarts, pod_age, namespace: namespace, client: client) }

    it 'sets the pod name field' do
      expect(subject.name).to eq pod_name
    end

    it 'sets the pod ready field' do
      expect(subject.ready).to eq pod_ready
    end

    it 'sets the pod status field' do
      expect(subject.status).to eq pod_status
    end

    it 'sets the pod restarts field' do
      expect(subject.restarts).to eq pod_restarts
    end

    it 'sets the pod age field' do
      expect(subject.age).to eq pod_age
    end

    it 'sets the pod namespace' do
      expect(subject.namespace).to eq namespace
    end

    it 'sets the client' do
      expect(subject.client).to eq client
    end
  end

  describe '#running?' do
    subject { Kubecontrol::Pod.new(pod_name, pod_ready, pod_status, pod_restarts, pod_age).running? }

    context 'is running' do
      it { is_expected.to eq true }
    end

    context 'is NOT running' do
      let(:pod_status) { 'Terminated' }

      it { is_expected.to eq false }
    end
  end

  describe '#stopped?' do
    subject { Kubecontrol::Pod.new(pod_name, pod_ready, pod_status, pod_restarts, pod_age).stopped? }

    context 'is running' do
      it { is_expected.to eq false }
    end

    context 'is NOT running' do
      let(:pod_status) { 'Terminated' }

      it { is_expected.to eq true }
    end
  end

  describe '#exec' do
    let(:command) { 'ls' }
    let(:kubectl_command) { "exec -i #{pod.name} -- sh -c \"#{command.gsub('"', '\"')}\"" }
    let(:std_out) { "bin\ndev\netc\nhome\nlib" }
    let(:std_err) { '' }
    let(:status_code) { 0 }
    let(:kubectl_command_response) { [std_out, std_err, status_code] }
    let(:pod) { Kubecontrol::Pod.new(pod_name, pod_ready, pod_status, pod_restarts, pod_age, namespace: namespace, client: client) }

    subject { pod.exec(command) }

    it 'sends the exec command via Kubecontrol::Client#kubectl_command' do
      expect(pod.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      subject
    end

    it 'returns an array of std_out, std_err, and status code' do
      allow(pod.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      std_out_response, std_err_response, status_code_response  = subject
      expect(std_out_response).to eq std_out
      expect(std_err_response).to eq std_err
      expect(status_code_response).to eq status_code
    end
  end
end
