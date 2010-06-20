$informer_indent = 0

module Tumbler
  module Informer
    
    Colors = [:green, :cyan, :blue, :magenta]
    
    def inform(msg, &block)
      $stderr.puts(' ' * $informer_indent << msg.color(Colors[$informer_indent % Colors.size]))
      $informer_indent += 1
      begin
        block.call if block
      rescue Exception
        $stderr.puts "#{msg} failed!".color(:red)
        raise
      ensure
        $informer_indent -= 1
      end
    end
  end
end