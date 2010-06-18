# -*- encoding: utf-8 -*-

require 'lib/tumbler/gemspec'

Gem::Specification.new do |s|
  s.name = Tumbler::Gemspec.name
  s.version = Tumbler::Gemspec.version

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubyforge_project = Tumbler::Gemspec.name
  s.authors = ["Joshua Hull"]
  s.date = Tumbler::Gemspec.date
  s.description = "Let's make gem development fun and remove all the repetition! Tumbler provides support for common gem management tasks which helps you spend less time dealing with gem releases and more time focusing on your gem functionality!"
  s.summary = "Common gem generation and management tasks"
  s.email = %q{joshbuddy@gmail.com}
  s.extra_rdoc_files = Tumbler::Gemspec.files('README.rdoc')
  s.files = Tumbler::Gemspec.files
  s.homepage = %q{http://github.com/joshbuddy/tumbler}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.test_files = Tumbler::Gemspec.files(/^spec/)
  s.executables = Tumbler::Gemspec.bin_files

  # dependencies
  Tumbler::Gemspec.inject_dependencies(s)
end
