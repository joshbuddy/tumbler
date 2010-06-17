module Tumbler
  module Runner

    attr_accessor :noop

    def sh(cmd)
      output, code = sh_with_code(cmd)
      code == 0 ? output : raise(output)
    end

    def dry(message)
      puts message
    end

    def sh_with_code(cmd)
      if noop
        dry("Running `#{cmd}'")
        ['' , 0]
      else
        output = ''
        Dir.chdir(base) { output = `#{cmd}` }
        [output, $?]
      end
    end
  end
end