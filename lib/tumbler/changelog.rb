require 'tempfile'
require 'fileutils'

class Tumbler
  class Changelog
    include Runner

    DEFAULT_FILE = 'CHANGELOG'

    attr_reader :file

    def initialize(manager, &block)
      @manager = manager
      instance_eval(&block) if block
    end

    def filename(file)
      @basefile = file
      @file = File.join(@manager.base, file)
    end

    def write_version_header
      prepend "== #{@manager.version}\n\n"
    end

    def prepend(data)
      if @manager.noop
        @manager.dry "Prepending #{data} to #{@basefile}"
      else
        Tempfile.open('changelog') do |tmp|
          tmp.puts data
          File.open(@file) do |f|
            f.each do |line|
              tmp << line
            end
          end
          tmp.close
          FileUtils.copy(tmp.path, @file)
          File.unlink(tmp.path)
        end
      end
    end

    def update
      ensure_existence
      prepend("\n")
      prepend(@manager.latest_changes.inject('') { |changes, change| changes << "* #{change.summary} (#{change.author}, #{change.hash})\n" })
    end

    def ensure_existence
      File.open(@file, 'w') {|f| f << ''} unless File.exist?(@file)
    end

    def commit
      sh "git commit #{@basefile} -m'Updated changelog'"
    end

    def base
      @manager.base
    end
  end
end