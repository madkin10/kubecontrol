module Kubecontrol
  class StatefulSet
    RESOURCE_NAME = 'statefulset'.freeze

    attr_reader :name, :ready, :age, :namespace, :client

    def initialize(name, ready, up_to_date, available, age, namespace, client)
      @name = name
      @ready = ready
      @age = age
      @namespace = namespace
      @client = client
    end

    def ready?
      @ready.split('/').first != '0'
    end

    def all_ready?
      max_pods = @ready.split('/').last
      @ready == "#{max_pods}/#{max_pods}"
    end

    def scale(count)
      @client.kubectl_command("scale statefulset #{@name} --replicas=#{count}")
    end
  end
end
