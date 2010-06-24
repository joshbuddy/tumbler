require 'callsite'
require 'versionomy'
require 'bundler'
require 'rainbow'

Callsite.activate_kernel_dir_methods

$LOAD_PATH << __DIR__

require 'ext/bundler'

require 'tumbler/informer'
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

  def self.load(base, name = nil)
    gemspecs = Dir[File.join(base, '*.gemspec')]
    case gemspecs.size
    when 0
      raise "#{base} contains no gemspecs"
    when 1
      Manager.new(gemspecs.first)
    else
      if name
        Manager.new(File.join(base, "#{name}.gemspec"))
      else
        raise "There are multiple gemspecs in #{base}. Specify the exact one."
      end
    end
  end
end