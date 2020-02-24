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

  let(:secret_type) { 'Opaque' }
  let(:secret_data) { '5' }
  let(:get_secrets_std_out) do
    <<~RUBY
      NAME     TYPE            DATA            AGE
      #{name}  #{secret_type}  #{secret_data}  #{age}
    RUBY
  end
  let(:get_secrets_std_err) { '' }
  let(:get_secrets_response) { [get_secrets_std_out, get_secrets_std_err, process_status] }

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

  describe '#kubectl_command' do
    let(:command) { 'get pods' }

    subject { Kubecontrol::Client.new.kubectl_command(command) }

    before do
      allow(Open3).to receive(:capture3).and_return get_pods_response
    end

    it 'sends a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with("kubectl -n default #{command}").and_return get_pods_response
      subject
    end

    it 'returns an array of std_out, std_err, and status code' do
      std_out_response, std_err_response, status_code_response  = subject
      expect(std_out_response).to eq get_pods_std_out
      expect(std_err_response).to eq get_pods_std_err
      expect(status_code_response).to eq process_status
    end
  end

  describe '#apply' do
    let(:std_out) { 'deployment.extensions/deployment configured' }
    let(:std_err) { '' }
    let(:apply_response) { ['deployment.extensions/deployment configured', '', process_status] }

    before do
      allow(Open3).to receive(:capture3).and_return apply_response
    end

    context 'missing file path or kustomization dir keyword arguments' do
      subject { Kubecontrol::Client.new.apply }

      it 'raises an ArgumentError' do
        expect{subject}.to raise_error(ArgumentError)
      end
    end

    context 'with both file path and kustomization dir keyword arguments' do
      subject { Kubecontrol::Client.new.apply(file_path: 'foo', kustomization_dir: 'bar') }

      it 'raises an ArgumentError' do
        expect{subject}.to raise_error(ArgumentError)
      end
    end

    context 'with a file path' do
      let(:file_path) { 'foo/bar/deployment.yaml' }

      subject { Kubecontrol::Client.new.apply(file_path: file_path) }

      it 'send a kubectl request to the command line' do
        expect(Open3).to receive(:capture3).with("kubectl -n default apply -f #{file_path}").and_return apply_response
        subject
      end

      it 'returns an array of std_out, std_err, and status code' do
        std_out_response, std_err_response, status_code_response  = subject
        expect(std_out_response).to eq std_out
        expect(std_err_response).to eq std_err
        expect(status_code_response).to eq process_status
      end
    end

    context 'with a kustomization directory' do
      let(:kustomization_dir) { 'foo/bar/kustomization' }

      subject { Kubecontrol::Client.new.apply(kustomization_dir: kustomization_dir) }

      it 'send a kubectl request to the command line' do
        expect(Open3).to receive(:capture3).with("kubectl -n default apply -k #{kustomization_dir}").and_return apply_response
        subject
      end

      it 'returns an array of std_out, std_err, and status code' do
        std_out_response, std_err_response, status_code_response  = subject
        expect(std_out_response).to eq std_out
        expect(std_err_response).to eq std_err
        expect(status_code_response).to eq process_status
      end
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
      expect(result.first).to be_an_instance_of Kubecontrol::Resources::Pod
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

    it { is_expected.to be_an_instance_of Kubecontrol::Resources::Pod }

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
      expect(result.first).to be_an_instance_of Kubecontrol::Resources::Service
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

    it { is_expected.to be_an_instance_of Kubecontrol::Resources::Service }

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
      expect(result.first).to be_an_instance_of Kubecontrol::Resources::Deployment
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

    it { is_expected.to be_an_instance_of Kubecontrol::Resources::Deployment }

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
      expect(result.first).to be_an_instance_of Kubecontrol::Resources::StatefulSet
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

    it { is_expected.to be_an_instance_of Kubecontrol::Resources::StatefulSet }

    it 'returns the correct stateful_sets' do
      expect(subject.name).to eq name
    end

    context 'stateful_set does not exist' do
      let(:get_stateful_sets_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#secrets' do
    subject { Kubecontrol::Client.new.secrets }

    it 'send a kubectl request to the command line' do
      expect(Open3).to receive(:capture3).with('kubectl -n default get secrets').and_return get_secrets_response
      subject
    end

    it 'returns an array of Kubecontrol::Secret' do
      allow(Open3).to receive(:capture3).and_return get_secrets_response
      result = subject
      expect(result).to be_an_instance_of Array
      expect(result.length).to eq 1
      expect(result.first).to be_an_instance_of Kubecontrol::Resources::Secret
    end

    context 'no secrets found' do
      let(:get_secrets_std_out) { '' }

      before do
        allow(Open3).to receive(:capture3).and_return get_secrets_response
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_secret_by_name' do
    subject { Kubecontrol::Client.new.find_secret_by_name(name) }

    before do
      allow(Open3).to receive(:capture3).and_return get_secrets_response
    end

    it { is_expected.to be_an_instance_of Kubecontrol::Resources::Secret }

    it 'returns the correct secrets' do
      expect(subject.name).to eq name
    end

    context 'secret does not exist' do
      let(:get_secrets_std_out) { '' }

      it { is_expected.to be_nil }
    end
  end
end
