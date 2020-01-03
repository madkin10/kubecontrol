module Kubecontrol
  class Container
    attr_reader :id, :image, :image_id, :last_state, :name, :ready, :restart_count, :state

    def initialize(container_ostruct_data)
      @id = container_ostruct_data.containerID
      @image = container_ostruct_data.image
      @image_id = container_ostruct_data.imageID
      @last_state = container_ostruct_data.lastState
      @name = container_ostruct_data.name
      @ready = container_ostruct_data.ready
      @restart_count = container_ostruct_data.restartCount
      @state = container_ostruct_data.state
    end
  end
end
