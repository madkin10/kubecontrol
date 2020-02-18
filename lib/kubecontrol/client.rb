require 'open3'
require_relative 'pod'
require_relative 'service'

module Kubecontrol
  class Client
    DEFAULT_NAMESPACE = 'default'.freeze

    attr_accessor :namespace

    def initialize(namespace = DEFAULT_NAMESPACE)
      @namespace = namespace
    end

    def deployments
      get_deployments_result, _stderr, _exit_code = kubectl_command('get deployments')
      return [] if get_deployments_result.empty?

      deployments_array = get_deployments_result.split
      deployments_array.shift(5) # remove output table headers
      deployments_array.each_slice(5).map do |deployments_data|
        Deployment.new(*deployments_data, namespace, self)
      end
    end

    def statefulsets
      get_statefulsets_result, _stderr, _exit_code = kubectl_command('get statefulsets')
      return [] if get_statefulsets_result.empty?

      statefulsets_array = get_statefulsets_result.split
      statefulsets_array.shift(3) # remove output table headers
      statefulsets_array.each_slice(3).map do |statefulsets_data|
        StatefulSet.new(*statefulsets_data, namespace, self)
      end
    end

    def pods
      get_resource(Pod, 5)
    end

    def find_pod_by_name(name_regex)
      pods.find { |pod| pod.name.match?(name_regex) }
    end

    def services
      get_resource(Service, 6)
    end

    def kubectl_command(command)
      stdout_data, stderr_data, status = Open3.capture3("kubectl -n #{namespace} #{command}")
      exit_code = status.exitstatus

      [stdout_data, stderr_data, exit_code]
    end

    private

    def get_resource(klass, number_of_columns)
      get_result, _stderr, _exit_code = kubectl_command("get #{klass::RESOURCE_NAME}")
      return [] if get_result.empty?

      resources_array = get_result.split
      resources_array.shift(number_of_columns) # remove output table headers
      resources_array.each_slice(number_of_columns).map do |resource_data|
        klass.new(*resource_data, namespace, self)
      end
    end
  end
end
