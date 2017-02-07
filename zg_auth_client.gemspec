# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zg_auth_client/version'

Gem::Specification.new do |spec|
  spec.name          = "zg_auth_client"
  spec.version       = ZgAuthClient::VERSION
  spec.authors       = ["sergocap"]
  spec.email         = ["systemofadown.2013@yandex.ru"]

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'


  spec.add_dependency 'config'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'daemons'
  spec.add_dependency 'rails'
end
