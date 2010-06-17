require File.join(File.dirname(__FILE__), '..', 'tumbler') unless Kernel.const_defined?(:Tumbler)
root = File.expand_path(File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /\.gemspec$/}.filename))
Tumbler.send(:remove_const, :Gemspec) if (Tumbler.const_defined?(:Gemspec))
Tumbler::Gemspec = Tumbler::GemspecHelper.new(Tumbler.load(root))