lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kubecontrol/version'

Gem::Specification.new do |spec|
  spec.name          = 'kubecontrol'
  spec.version       = Kubecontrol::VERSION
  spec.authors       = ['Marco Adkins']
  spec.email         = ['marcoadkins88@gmail.com']

  spec.summary       = 'Simple ruby wrapper for `kubectl` commands'
  spec.homepage      = 'https://github.com/madkin10/kubecontrol'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/madkin10/kubecontrol'
  spec.metadata['changelog_uri'] = 'https://github.com/madkin10/kubecontrol/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
end
