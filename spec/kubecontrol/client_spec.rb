require_relative '../spec_helper'

RSpec.describe Kubecontrol::Client do
  let(:custom_namespace) { 'custom_namespace' }
  let(:name) { 'foo_pod' }
  let(:ready) { '1/1' }
  let(:age) { '20d' }
  let(:process_status) do
    fork { exit }
    $CHILD_STATUS
  end

  let(:pod_status) { 'Running' }
  let(:pod_restarts) { '0' }
  let(:get_pods_std_out) do
    <<~RUBY
      NAME     READY     STATUS         RESTARTS         AGE
      #{name}  #{ready}  #{pod_status}  #{pod_restarts}  #{age}
    RUBY
  end
  let(:get_pods_std_err) { '' }
  let(:get_pods_response) { [get_pods_std_out, get_pods_std_err, process_status] }

  let(:service_type) { 'ClusterIP' }
  let(:service_cluster_ip) { '172.20.0.1' }
  let(:service_external_ip) { '<none>' }
  let(:service_ports) { '443/TCP' }
  let(:get_services_std_out) do
    <<~RUBY
      NAME     TYPE             CLUSTER_IP             EXTERNAL-IP             PORT(S)           AGE
      #{name}  #{service_type}  #{service_cluster_ip}  #{service_external_ip}  #{service_ports}  #{age}
    RUBY
  end
  let(:get_services_std_err) { '' }
  let(:get_services_response) { [get_services_std_out, get_services_std_err, process_status] }

  let(:deployments_up_to_date) { '1' }
  let(:deployments_available) { '1' }
  let(:get_deployments_std_out) do
    <<~RUBY
      NAME     READY     UP-TO-DATE                 AVAILABLE                 AGE
      #{name}  #{ready}  #{deployments_up_to_date}  #{deployments_available}  #{age}
    RUBY
  end
  let(:get_deployments_std_err) { '' }
  let(:get_deployments_response) { [get_deployments_std_out, get_deployments_std_err, process_status] }

  let(:get_stateful_sets_std_out) do
    <<~RUBY
      NAME     READY     AGE
      #{name}  #{ready}  #{age}
    RUBY
  end
  let(:get_stateful_sets_std_err) { '' }
  let(:get_stateful_sets_response) { [get_stateful_sets_std_out, get_stateful_sets_std_err, process_status] }

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
    subject { Kubecontrol::Client.new.find_pod_by_name(name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_pods_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::Pod }

    it 'returns the correct pod' do
      expect(subject.name).to eq name
    end

    context 'pod does not exist' do
      let(:get_pods_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#services' do
    subject { Kubecontrol::Client.new.services }

    it 'send a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with('kubectl -n default get services').and_return get_services_response
      subject
    end

    it 'returns an array of Kubecontrol::Services' do
      allow(Open3).to receive(:capture3).and_return get_services_response
      result = subject
      expect(result).to be_an_instance_of Array
      expect(result.length).to eq 1
      expect(result.first).to be_an_instance_of Kubecontrol::Service
    end

    context 'no services found' do
      let(:get_services_std_out) { '' }

      before do
        allow(Open3).to receive(:capture3).and_return get_services_response
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_service_by_name' do
    subject { Kubecontrol::Client.new.find_service_by_name(name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_services_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::Service }

    it 'returns the correct service' do
      expect(subject.name).to eq name
    end

    context 'service does not exist' do
      let(:get_services_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#deployments' do
    subject { Kubecontrol::Client.new.deployments }

    it 'send a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with('kubectl -n default get deployments').and_return get_deployments_response
      subject
    end

    it 'returns an array of Kubecontrol::Deployments' do
      allow(Open3).to receive(:capture3).and_return get_deployments_response
      result = subject
      expect(result).to be_an_instance_of Array
      expect(result.length).to eq 1
      expect(result.first).to be_an_instance_of Kubecontrol::Deployment
    end

    context 'no deployments found' do
      let(:get_deployments_std_out) { '' }

      before do
        allow(Open3).to receive(:capture3).and_return get_deployments_response
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_deployment_by_name' do
    subject { Kubecontrol::Client.new.find_deployment_by_name(name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_deployments_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::Deployment }

    it 'returns the correct deployment' do
      expect(subject.name).to eq name
    end

    context 'deployment does not exist' do
      let(:get_deployments_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#stateful_sets' do
    subject { Kubecontrol::Client.new.stateful_sets }

    it 'send a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with('kubectl -n default get statefulsets').and_return get_stateful_sets_response
      subject
    end

    it 'returns an array of Kubecontrol::StatefulSet' do
      allow(Open3).to receive(:capture3).and_return get_stateful_sets_response
      result = subject
      expect(result).to be_an_instance_of Array
      expect(result.length).to eq 1
      expect(result.first).to be_an_instance_of Kubecontrol::StatefulSet
    end

    context 'no stateful_sets found' do
      let(:get_stateful_sets_std_out) { '' }

      before do
        allow(Open3).to receive(:capture3).and_return get_stateful_sets_response
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_stateful_set_by_name' do
    subject { Kubecontrol::Client.new.find_stateful_set_by_name(name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_stateful_sets_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::StatefulSet }

    it 'returns the correct stateful_sets' do
      expect(subject.name).to eq name
    end

    context 'stateful_set does not exist' do
      let(:get_stateful_sets_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end
end
