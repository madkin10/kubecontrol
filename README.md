# Kubecontrol

Simple ruby wrapper for `kubectl` commands

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kubecontrol'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kubecontrol

## Usage

##### kubectl Commands
```ruby
require 'kubecontrol'

# create new client
kubectl_client =  Kubecontrol.client.new

#Exec an arbitrary kubectl command
std_out, std_err, exit_code = kubectl_client.kubectl_command 'get deployments'
```

#### Pods

```ruby
require 'kubecontrol'

# create new client
kubectl_client =  Kubecontrol.client.new

# all pods for namespace
pods = kubectl_client.pods

# find pod by name regex
pod = kubectl_client.find_pod_by_name /foo-api-.*/

# access pod information
pod.name
pod.ready
pod.status
pod.restarts
pod.age
pod.namespace

#exec commands on a pod
std_out, std_err, exit_code = pod.exec('ls')
```

#### Services

```ruby
require 'kubecontrol'

# create new client
kubectl_client =  Kubecontrol.client.new

# all services for namespace
services = kubectl_client.services

# access service information
service.name
service.type
service.cluster_ip
service.external_ip
service.ports
service.age
service.namespace
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/madkin10/kubecontrol.
