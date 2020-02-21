require 'kubecontrol/version'
require 'kubecontrol/client'
require 'kubecontrol/pod'
require 'kubecontrol/service'
require 'kubecontrol/stateful_set'
require 'kubecontrol/deployment'

module Kubecontrol
  class Error < StandardError; end
end
