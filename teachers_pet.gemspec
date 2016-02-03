# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teachers_pet/version'

Gem::Specification.new do |spec|
  spec.name          = "brown_noser"
  spec.version       = TeachersPet::VERSION
  spec.authors       = ["Paul Scarrone"]
  spec.email         = ["paul.scarrone@gmail.com"]

  spec.summary       = %q{Helps with mundane tasks associated with grading github assignments}
  spec.description   = %q{Will organize repos using github workflow}
  spec.homepage      = "https://github.com/WCCCEDU/github_grading_tools_rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ['pet']
  spec.require_paths = ["lib"]


  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.3"
  spec.add_development_dependency "awesome_print", "1.6.1"
end
