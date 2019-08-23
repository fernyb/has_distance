# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'has_distance/version'

Gem::Specification.new do |spec|
  spec.name          = "has_distance"
  spec.version       = HasDistance::VERSION
  spec.authors       = ["Fernando Barajas"]
  spec.email         = ["fernyb@fernyb.net"]
  spec.description   = %q{Used to find nearby records via latitude/longitude}
  spec.summary       = %q{Adds has_distance to ActiveRecord}
  spec.homepage      = "http://github.com/fernyb/has_distance"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "csv-mapper"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rails", ">= 3.0.0"
end
