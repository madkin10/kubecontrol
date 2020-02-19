require 'open3'
require_relative 'pod'
require_relative 'deployment'
require_relative 'statefulset'
require_relative 'service'

module Kubecontrol
  class Client
    DEFAULT_NAMESPACE = 'default'.freeze

    attr_accessor :namespace

    def initialize(namespace = DEFAULT_NAMESPACE)
      @namespace = namespace
    end

    def pods
      get_resource(Pod, 5)
    end

    def deployments
      get_resource(Deployment, 5)
    end

    def statefulsets
      get_resource(StatefulSet, 3)
    end

    def services
      get_resource(Service, 6)
    end

    def find_pod_by_name(name_regex)
      pods.find { |pod| pod.name.match?(name_regex) }
    end

    def find_deployment_by_name(name_regex)
      deployments.find { |deployment| deployment.name.match?(name_regex) }
    end

    def find_statefulset_by_name(name_regex)
      statefulsets.find { |statefulset| statefulset.name.match?(name_regex) }
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
      resources_array.shift number_of_columns # remove output table headers
      resources_array.each_slice(number_of_columns).map do |resource_data|
        klass.new(*resource_data, namespace, self)
      end
    end
  end
end
