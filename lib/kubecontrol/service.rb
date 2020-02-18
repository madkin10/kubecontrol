module Kubecontrol
  class Service
    RESOURCE_NAME = 'services'.freeze

    attr_reader :name, :age, :type, :cluster_ip, :external_ip, :ports, :namespace, :client

    def initialize(name, type, cluster_ip, external_ip, ports, age, namespace, client)
      @name = name
      @age = age
      @type = type
      @cluster_ip = cluster_ip
      @external_ip = external_ip
      @ports = ports
      @namespace = namespace
      @client = client
    end
  end
end
