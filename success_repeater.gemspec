# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'success_repeater/version'

Gem::Specification.new do |spec|
  spec.name          = "success_repeater"
  spec.version       = SuccessRepeater::VERSION
  spec.authors       = ["luigi.sk"]
  spec.email         = ["luigi.sk@gmail.com"]
  spec.description   = %q{repeat yield command in transaction until is executed successfully}
  spec.summary       = %q{devel}
  spec.homepage      = "https://github.com/luigi-sk/success-repeater"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "test-unit"
end
