require 'open3'
require_relative 'pod'

module Kubecontrol
  class Client
    DEFAULT_NAMESPACE = 'default'.freeze

    attr_accessor :namespace

    def initialize(namespace = DEFAULT_NAMESPACE)
      @namespace = namespace
    end

    def pods
      get_pods_result, _stderr, _exit_code = kubectl_command('get pods')
      return [] if get_pods_result.empty?

      pods_array = get_pods_result.split
      pods_array.shift 5 # remove output table headers
      pods_array.each_slice(5).map do |pod_data|
        Pod.new(*pod_data, namespace, self)
      end
    end

    def find_pod_by_name(name_regex)
      pods.find { |pod| pod.name.match?(name_regex) }
    end

    def kubectl_command(command)
      stdout_data, stderr_data, status = Open3.capture3("kubectl -n #{namespace} #{command}")
      exit_code = status.exitstatus

      [stdout_data, stderr_data, exit_code]
    end
  end
end
