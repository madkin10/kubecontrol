module Kubecontrol
  module Resources
    class Deployment
      RESOURCE_NAME = 'deployments'.freeze

      attr_reader :name, :ready, :up_to_date, :available, :age, :namespace, :client

      def initialize(name, ready, up_to_date, available, age, namespace, client)
        @name = name
        @ready = ready
        @up_to_date = up_to_date
        @available = available
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

      def available?
        @available.to_i > 1
      end

      def up_to_date?
        @up_to_date.to_i > 1
      end

      def scale(count)
        @client.kubectl_command("scale deployment #{@name} --replicas=#{count}")
      end
    end
  end
end
