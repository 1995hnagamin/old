# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'old/version'

Gem::Specification.new do |spec|
  spec.name          = "old"
  spec.version       = Old::VERSION
  spec.authors       = ["Hideaki Nagamine"]
  spec.email         = ["1995.hnagamin@gmail.com"]

  spec.summary       = %q{CLI tool to view On-Line Document for contained objects.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/1995hnagamin/old"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6.7"
  spec.add_dependency "mechanize", "~> 2.7.3"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
