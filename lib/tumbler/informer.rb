$informer_indent = 0

module Tumbler
  module Informer
    def inform(msg, &block)
      $stderr.puts (' ' * $informer_indent << msg)
      $informer_indent += 1
      begin
        block.call if block
      rescue Exception
        $stderr.puts " #{msg} failed!"
        raise
      ensure
        $informer_indent -= 1
      end
    end
  end
end