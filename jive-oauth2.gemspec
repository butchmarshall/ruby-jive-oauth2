# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jive/oauth2/version'

Gem::Specification.new do |spec|
	spec.name          = "jive-oauth2"
	spec.version       = Jive::OAuth2::VERSION
	spec.authors       = ["Butch Marshall"]
	spec.email         = ["butch.a.marshall@gmail.com"]

	spec.summary       = %q{Basic OAuth2 support for Jive}
	spec.description   = %q{Utility functions for dealing with OAuth2 and Jive}
	spec.homepage      = "https://github.com/butchmarshall/jive-OAuth2"
	spec.license       = "MIT"

	spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
	spec.bindir        = "exe"
	spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

	spec.add_dependency "cgi-query_string", "~> 0.1.0"

	spec.add_development_dependency "bundler", "~> 1.10"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec"
end
