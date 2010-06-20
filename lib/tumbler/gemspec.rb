warn <<-HERE_DOC
It's probably a lot better to use Tumbler within your gemspec the follow way:

  require 'tumbler'
  tumbler = Tumbler::GemspecHelper.new

As opposed to:

  require 'tumbler/gemspec'

The gemspec helper will have all the same methods as the Tumbler::Gemspec constant used before.
HERE_DOC

require File.join(File.dirname(__FILE__), '..', 'tumbler') unless Kernel.const_defined?(:Tumbler)
root = File.expand_path(File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /\.gemspec$/}.filename))
Tumbler.send(:remove_const, :Gemspec) if (Tumbler.const_defined?(:Gemspec))
Tumbler::Gemspec = Tumbler::GemspecHelper.new(Tumbler.load(root))