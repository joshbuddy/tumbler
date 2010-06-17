module Tumbler
  class Manager
    class Version
      include Runner

      attr_reader :file, :basefile, :field_names

      DEFAULT_FIELD = [:major, :minor, :tiny]
      INITIAL_VERSION = '0.0.0'

      def initialize(manager, &block)
        @manager = manager
        filename(manager.default_version_file)
        fields(manager.default_version_file)
        instance_eval(&block) if block
      end

      def fields(f)
        @field_names = (f == :all ? @version.field_names : f)
      end

      def reload
        p extract
        @version = Versionomy.parse(File.exist?(file) ? extract : '0.0.0')
      end  

      def extract
        File.read(file)[/Version\s*=\s*['"](.*?)['"]/i, 1]
      end

      def generate_with_new(version)
        File.read(file).gsub(/(Version\s*=\s*['"])(.*?)(['"])/i, "$1#{version}$3")
      end

      def filename(file)
        @basefile = file
        @file = File.join(@manager.base, file)
      end

      def value
        @version
      end

      def to_s
        value.to_s
      end

      def bump(level)
        if @manager.noop
          @manager.dry "Bumping version to #{bump(level).to_s}"
        else
          File.open(file, 'w') {|f| f << generate_with_new(@version.bump(level).to_s)}
          reload
        end
      end
    
      def commit(from)
        sh "git commit #{@basefile} -m'Bumped version from #{from} to #{to_s}'"
      end
    
      def base
        @manager.base
      end
    end
  end
end