lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kubecontrol/version'

Gem::Specification.new do |spec|
  spec.name          = 'kubecontrol'
  spec.version       = Kubecontrol::VERSION
  spec.authors       = ['Marco Adkins', 'Dustin Ashley']
  spec.email         = ['marcoadkins88@gmail.com']

  spec.summary       = 'Simple ruby wrapper for `kubectl` commands'
  spec.homepage      = 'https://github.com/madkin10/kubecontrol'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/madkin10/kubecontrol'
  spec.metadata['changelog_uri'] = 'https://github.com/madkin10/kubecontrol/blob/master/CHANGELOG.md'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.17'
end
