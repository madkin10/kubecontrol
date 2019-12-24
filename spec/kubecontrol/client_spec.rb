require_relative '../spec_helper'

RSpec.describe Kubecontrol::Client do
  let(:custom_namespace) { 'custom_namespace' }
  let(:pod_name) { 'foo_pod' }
  let(:pod_ready) { '1/1' }
  let(:pod_status) { 'Running' }
  let(:pod_restarts) { '0' }
  let(:pod_age) { '20d' }

  let(:get_pods_std_out) do
    <<~RUBY
      NAME         READY         STATUS         RESTARTS         AGE
      #{pod_name}  #{pod_ready}  #{pod_status}  #{pod_restarts}  #{pod_age}
    RUBY
  end
  let(:get_pods_std_err) { '' }
  let(:process_status) do
    fork { exit }
    $CHILD_STATUS
  end
  let(:get_pods_response) { [get_pods_std_out, get_pods_std_err, process_status] }

  describe '#initialize' do
    subject { Kubecontrol::Client }

    it 'defaults the namespace' do
      expect(subject.new.namespace).to eq Kubecontrol::Client::DEFAULT_NAMESPACE
    end

    it 'accepts namespace as a parameter' do
      expect(subject.new(custom_namespace).namespace).to eq custom_namespace
    end
  end

  describe '#namespace=' do
    subject { Kubecontrol::Client.new }
    it 'updates the namespace on the class' do
      expect { subject.namespace = custom_namespace }
        .to change(subject, :namespace)
        .from(Kubecontrol::Client::DEFAULT_NAMESPACE)
        .to(custom_namespace)
    end
  end

  describe '#namespace' do
    subject { Kubecontrol::Client.new }
    it 'returns the namespace on the class' do
      expect(subject.namespace).to eq Kubecontrol::Client::DEFAULT_NAMESPACE
    end
  end

  describe '#pods' do
    subject { Kubecontrol::Client.new.pods }

    it 'send a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with('kubectl -n default get pods').and_return get_pods_response
      subject
    end

    it 'returns an array of Kubecontrol::Pods' do
      allow(Open3).to receive(:capture3).and_return get_pods_response
      result = subject
      expect(result).to be_an_instance_of Array
      expect(result.length).to eq 1
      expect(result.first).to be_an_instance_of Kubecontrol::Pod
    end

    context 'no pods found' do
      let(:get_pods_std_out) { '' }

      before do
        allow(Open3).to receive(:capture3).and_return get_pods_response
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_pod_by_name' do
    subject { Kubecontrol::Client.new.find_pod_by_name(pod_name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_pods_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::Pod }

    it 'returns the correct pod' do
      expect(subject.name).to eq pod_name
    end

    context 'pod does not exist' do
      let(:get_pods_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end
end
