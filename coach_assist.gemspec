# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coach_assist/version'

Gem::Specification.new do |spec|
  spec.name          = "coach_assist"
  spec.version       = CoachAssist::VERSION
  spec.authors       = ["Urs Gerber"]
  spec.email         = ["ug.gerber@gmail.com"]

  spec.summary       = %q{Ruby gem to interface with the UniFR Cybercoach REST server}
  #spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/moose-secret-agents/coach_assist"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"

  spec.add_dependency 'httparty', '~> 0.13.7'
  spec.add_dependency 'hashie', '~> 3.4.2'
  spec.add_dependency 'activesupport', '~> 4.2'
end
