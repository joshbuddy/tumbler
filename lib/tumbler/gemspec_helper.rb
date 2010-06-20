module Tumbler
  class GemspecHelper
    def initialize(manager = nil)
      unless manager
        root = File.expand_path(File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /\.gemspec$/}.filename))
        manager = Tumbler.load(root)
      end
      @manager = manager
    end

    def version
      @manager.version.to_s
    end

    def name
      @manager.name
    end

    def git_files
      @git_files ||= Dir.chdir(@manager.base) { `git ls-files`.split("\n") }
    end

    def files(test = nil)
      git_files.select{|f| test.nil? or f.index(test) }
    end

    def bin_files
      git_files.select{|f| f[/^bin\//] }.map{|f| f[/bin\/(.*)/, 1]}
    end

    def inject_dependencies(gemspec)
      @manager.bundler.dependencies.each do |dep|
        gemspec.add_runtime_dependency(dep.name, *dep.requirements_list) if dep.groups.include?(:default)
        gemspec.add_development_dependency(dep.name, *dep.requirements_list) if dep.groups.include?(:development)
      end
    end

    def date
      Time.new.strftime("%Y-%m-%d")
    end
  end
end