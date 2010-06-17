require 'callsite'
require 'versionomy'
require 'bundler'

Callsite.activate_kernel_dir_methods

$LOAD_PATH << __DIR__

require 'tumbler/runner'
require 'tumbler/updater'
require 'tumbler/rake_tasks'
require 'tumbler/version'
require 'tumbler/gemspec_helper'
require 'tumbler/generate'
require 'tumbler/gem'
require 'tumbler/cli'
require 'tumbler/manager'

module Tumbler
  def self.use_rake_tasks(name = nil)
    root = File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /Rakefile/}.filename)
    Tumbler::RakeTasks.register(File.expand_path(root), name)
  end

  def self.load(base)
    File.exist?(File.join(base, 'Tumbler')) ? Manager.new(base) : nil
  end

end