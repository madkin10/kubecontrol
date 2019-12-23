require_relative '../spec_helper'

RSpec.describe Kubecontrol::Pod do
  let(:pod_name) { 'foo_pod' }
  let(:pod_ready) { '1/1' }
  let(:pod_status) { 'Running' }
  let(:pod_restarts) { '0' }
  let(:pod_age) { '20d' }

  describe '#initialize' do
    subject { Kubecontrol::Pod.new(pod_name, pod_ready, pod_status, pod_restarts, pod_age) }

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
end
