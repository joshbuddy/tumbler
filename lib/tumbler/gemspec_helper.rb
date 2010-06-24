module Tumbler
  class GemspecHelper
    def initialize
      @base = File.expand_path(File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /\.gemspec$/}.filename))
    end

    def git_files
      @git_files ||= Dir.chdir(@base) { `git ls-files`.split("\n") }
    end

    def files(test = nil)
      git_files.select{|f| test.nil? or f.index(test) }
    end

    def bin_files
      git_files.select{|f| f[/^bin\//] }.map{|f| f[/bin\/(.*)/, 1]}
    end

    def date
      Time.new.strftime("%Y-%m-%d")
    end
  end
end