require 'json'
require "base64"

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

      def data_values
        @data_values ||= begin
                           std_out, _std_err, exit_code = @client.kubectl_command("get secret #{@name} -o json")
                           if exit_code.zero?
                             json_secret = JSON.parse(std_out)
                             json_secret['data'].reduce({}) {|h, (k,v)|  h[k] = Base64.decode64(v); h }
                           else
                             {}
                           end
                         end
      end
    end
  end
end
