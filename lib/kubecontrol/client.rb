require_relative 'pod'

module Kubecontrol
  class Client
    DEFAULT_NAMESPACE = 'default'.freeze

    attr_accessor :namespace

    def initialize(namespace = DEFAULT_NAMESPACE)
      @namespace = namespace
    end

    def pods
      get_pods_result = kubectl_command('get pods')
      return [] if get_pods_result.empty?

      pods_array = get_pods_result.split
      pods_array.shift 5 # remove output table headers
      pods_array.each_slice(5).map do |pod_data|
        Pod.new(*pod_data)
      end
    end

    def find_pod_by_name(name_regex)
      pods.find { |pod| pod.name.match?(name_regex) }
    end

    private

    def kubectl_command(command)
      `kubectl -n #{namespace} #{command}`
    end
  end
end
