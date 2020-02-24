require_relative '../../spec_helper'
require_relative '../../../lib/kubecontrol/resources/service'

RSpec.describe Kubecontrol::Resources::Service do
  let(:service_name) { 'foo_service' }
  let(:service_age) { '2d' }
  let(:service_type) { 'ClusterIP' }
  let(:service_cluster_ip) { '172.20.0.1' }
  let(:service_external_ip) { '<none>' }
  let(:service_ports) { '443/TCP' }
  let(:namespace) { 'default' }
  let(:client) { Kubecontrol::Client.new }

  describe '#initialize' do
    subject { Kubecontrol::Resources::Service.new(service_name, service_type, service_cluster_ip, service_external_ip, service_ports, service_age, namespace, client) }

    it 'sets the service name field' do
      expect(subject.name).to eq service_name
    end

    it 'sets the service age field' do
      expect(subject.age).to eq service_age
    end

    it 'sets the service type field' do
      expect(subject.type).to eq service_type
    end

    it 'sets the service cluster ip field' do
      expect(subject.cluster_ip).to eq service_cluster_ip
    end

    it 'sets the service external ip field' do
      expect(subject.external_ip).to eq service_external_ip
    end

    it 'sets the service ports field' do
      expect(subject.ports).to eq service_ports
    end

    it 'sets the service namespace' do
      expect(subject.namespace).to eq namespace
    end

    it 'sets the client' do
      expect(subject.client).to eq client
    end
  end
end
