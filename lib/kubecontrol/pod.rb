require_relative './container'
require 'time'

module Kubecontrol
  class Pod
    RUNNING = 'Running'.freeze

    attr_reader :name, :ready, :status, :restarts, :age, :namespace, :client, :containers, :all_data

    def initialize(all_data, client)
      @name = all_data.metadata.name
      @containers = all_data.status.containerStatuses.map { |conatiner_status| Container.new conatiner_status }
      @ready = @containers.map(&:ready).all?
      @status = all_data.status.phase
      @restarts = @containers.map(&:restart_count).inject(:+)
      @age = (Time.now.utc - Time.parse(all_data.metadata.creationTimestamp)).round
      @namespace = all_data.metadata.namespace
      @all_data = all_data
      @client = client
    end

    def stopped?
      @status != RUNNING
    end

    def running?
      @status == RUNNING
    end

    def exec(command, container_name = nil)
      container_name_flag = container_name ? "-c #{container_name}" : ''
      @client.kubectl_command("exec -i #{name} #{container_name_flag} -- sh -c \"#{command.gsub('"', '\"')}\"")
    end
  end
end
