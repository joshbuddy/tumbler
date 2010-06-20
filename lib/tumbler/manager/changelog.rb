require 'tempfile'
require 'fileutils'

module Tumbler
  class Manager
    class Changelog
      include Runner
      include Informer

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
        inform "Writing version header to `#{@basefile}'" do
          prepend "== #{@manager.version}\n\n"
        end
      end

      def prepend(data)
        if @manager.noop
          @manager.dry "Prepending #{data} to `#{@basefile}'"
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
        inform "Updating `#{@basefile}' with latest changes" do
          prepend("\n")
          prepend(@manager.latest_changes.inject('') { |changes, change| changes << "* #{change.summary} (#{change.author}, #{change.hash})\n" })
        end
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
end