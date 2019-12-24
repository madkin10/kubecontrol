module Kubecontrol
  class Pod
    RUNNING = 'Running'.freeze

    attr_reader :name, :ready, :status, :restarts, :age, :namespace, :client

    def initialize(name, ready, status, restarts, age, namespace:, client:)
      @name = name
      @ready = ready
      @status = status
      @restarts = restarts
      @age = age
      @namespace = namespace
      @client = client
    end

    def stopped?
      @status != RUNNING
    end

    def running?
      @status == RUNNING
    end
  end
end
