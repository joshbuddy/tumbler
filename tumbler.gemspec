# -*- encoding: utf-8 -*-

require 'lib/tumbler'

tumbler = Tumbler::GemspecHelper.new

Gem::Specification.new do |s|
  s.name = tumbler.name
  s.version = tumbler.version

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubyforge_project = tumbler.name
  s.authors = ["Joshua Hull"]
  s.date = tumbler.date
  s.description = "Let's make gem development fun! Tumbler provides common gem management tasks using a common set of 'best practices' out of the box."
  s.summary = "Common gem generation and management tasks"
  s.email = %q{joshbuddy@gmail.com}
  s.extra_rdoc_files = tumbler.files('README.rdoc')
  s.files = tumbler.files
  s.homepage = %q{http://github.com/joshbuddy/tumbler}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.test_files = tumbler.files(/^spec/)
  s.executables = tumbler.bin_files

  # dependencies
  tumbler.inject_dependencies(s)
end
