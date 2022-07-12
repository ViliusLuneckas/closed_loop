# frozen_string_literal: true

require_relative "lib/closed_loop/version"

Gem::Specification.new do |spec|
  spec.name          = 'closed_loop'
  spec.version       = ClosedLoop::VERSION
  spec.authors       = ['Vilius Luneckas']
  spec.email         = ['vilius.luneckas@gmail.com']

  spec.summary       = 'State machine DSL'
  spec.homepage      = 'https://github.com/ViliusLuneckas/closed_loop'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
