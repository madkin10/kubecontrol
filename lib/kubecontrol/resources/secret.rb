module Kubecontrol
  module Resources
    class Secret
      RESOURCE_NAME = 'secrets'.freeze

      attr_reader :name, :type, :data, :age, :namespace, :client

      def initialize(name, type, data, age, namespace, client)
        @name = name
        @type = type
        @data = data
        @age = age
        @namespace = namespace
        @client = client
      end
    end
  end
end
