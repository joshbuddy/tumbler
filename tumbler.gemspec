# -*- encoding: utf-8 -*-

require 'lib/tumbler/version'

files = `git ls-files`.split("\n")

Gem::Specification.new do |s|
  s.name = 'tumbler'
  s.version = Tumbler::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubyforge_project = 'tumbler'
  s.authors = ["Joshua Hull"]
  s.date = Time.new.strftime("%Y-%m-%d")
  s.description = "Let's make gem development fun! Tumbler provides common gem management tasks using a common set of 'best practices' out of the box."
  s.summary = "Common gem generation and management tasks"
  s.email = %q{joshbuddy@gmail.com}
  s.extra_rdoc_files = files.select{|f| f == 'README.rdoc'}
  s.files = files
  s.homepage = %q{http://github.com/joshbuddy/tumbler}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.test_files = files.select{|f| f =~ /^test/}
  s.executables = files.select{|f| f =~ /^bin/}

  s.add_runtime_dependency 'callsite',   '>=0.0.2'
  s.add_runtime_dependency 'versionomy', '>=0.0.2'
  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'rainbow'
  s.add_runtime_dependency 'git'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'riot'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'blockenspiel'
end
