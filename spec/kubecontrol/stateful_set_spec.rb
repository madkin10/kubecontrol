require_relative '../spec_helper'
require_relative '../../lib/kubecontrol/deployment'

RSpec.describe Kubecontrol::Deployment do
  let(:deployment_name) { 'foo_deployment' }
  let(:deployment_age) { '2d' }
  let(:deployment_ready) { '1/1' }
  let(:deployment_up_to_date) { '1' }
  let(:deployment_available) { '1' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }
  let(:deployment) { Kubecontrol::Deployment.new(deployment_name, deployment_ready, deployment_up_to_date, deployment_available, deployment_age, namespace, client) }

  describe '#initialize' do
    subject { deployment }

    it 'sets the deployment name field' do
      expect(subject.name).to eq deployment_name
    end

    it 'sets the deployment age field' do
      expect(subject.age).to eq deployment_age
    end

    it 'sets the deployment ready field' do
      expect(subject.ready).to eq deployment_ready
    end

    it 'sets the deployment up to date field' do
      expect(subject.up_to_date).to eq deployment_up_to_date
    end

    it 'sets the deployment available field' do
      expect(subject.available).to eq deployment_available
    end

    it 'sets the deployment namespace' do
      expect(subject.namespace).to eq namespace
    end

    it 'sets the client' do
      expect(subject.client).to eq client
    end
  end

  describe '#ready?' do
    subject { deployment.ready? }

    context 'all replicas running' do
      let(:deployment_ready) { '3/3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not running' do
      let(:deployment_ready) { '2/3' }

      it { is_expected.to eq true }
    end

    context 'no replicas running' do
      let(:deployment_ready) { '0/3' }

      it { is_expected.to eq false }
    end
  end

  describe '#all_ready?' do
    subject { deployment.all_ready? }

    context 'all replicas running' do
      let(:deployment_ready) { '3/3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not running' do
      let(:deployment_ready) { '2/3' }

      it { is_expected.to eq false }
    end

    context 'no replicas running' do
      let(:deployment_ready) { '0/3' }

      it { is_expected.to eq false }
    end
  end

  describe '#available?' do
    subject { deployment.available? }

    context 'all replicas available' do
      let(:deployment_available) { '3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not available' do
      let(:deployment_available) { '2' }

      it { is_expected.to eq true }
    end

    context 'no replicas available' do
      let(:deployment_available) { '0' }

      it { is_expected.to eq false }
    end
  end

  describe '#up_to_date?' do
    subject { deployment.up_to_date? }

    context 'all replicas up to date' do
      let(:deployment_up_to_date) { '3' }

      it { is_expected.to eq true }
    end

    context 'some replicas not up to date' do
      let(:deployment_up_to_date) { '2' }

      it { is_expected.to eq true }
    end

    context 'no replicas up to date' do
      let(:deployment_up_to_date) { '0' }

      it { is_expected.to eq false }
    end
  end

  describe '#scale' do
    let(:scale_count) { '5' }

    let(:kubectl_command) { "scale deployment #{deployment_name} --replicas=#{scale_count}" }
    let(:std_out) { "deployment.extensions/#{deployment_name} scaled" }
    let(:std_err) { '' }
    let(:status_code) { 0 }
    let(:kubectl_command_response) { [std_out, std_err, status_code] }

    subject { deployment.scale(scale_count) }

    it 'sends the scale command via Kubecontrol::Client#kubectl_command' do
      expect(deployment.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      subject
    end

    it 'returns an array of std_out, std_err, and status code' do
      allow(deployment.client).to receive(:kubectl_command).with(kubectl_command).and_return kubectl_command_response
      std_out_response, std_err_response, status_code_response = subject
      expect(std_out_response).to eq std_out
      expect(std_err_response).to eq std_err
      expect(status_code_response).to eq status_code
    end
  end
end
