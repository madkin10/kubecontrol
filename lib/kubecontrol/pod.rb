module Kubecontrol
  class Pod
    RUNNING = 'Running'.freeze

    attr_reader :name, :ready, :status, :restarts, :age

    def initialize(name, ready, status, restarts, age)
      @name = name
      @ready = ready
      @status = status
      @restarts = restarts
      @age = age
    end

    def stopped?
      @status != RUNNING
    end

    def running?
      @status == RUNNING
    end
  end
end
