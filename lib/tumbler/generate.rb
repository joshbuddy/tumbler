require 'rubygems'
require 'erb'

class Tumbler
  class Generate
    
    include Runner
    
    def self.app(dir, name, opts = {})
      generator = Generate.new(dir, name)
      generator.version = opts[:version] if opts[:version]
      generator.changelog = opts[:changelog] if opts.key?(:changelog)
      generator.development_dependencies << ::Gem::Dependency.new('tumbler')
      if opts[:dependencies]
        Array(opts[:dependencies]).each do |dep|
          generator.dependencies << (dep.is_a?(Array) ? ::Gem::Dependency.new(*dep) : ::Gem::Dependency.new(dep))
        end
      end
      if opts[:development_dependencies]
        Array(opts[:development_dependencies]).each do |dep|
          generator.development_dependencies << (dep.is_a?(Array) ? ::Gem::Dependency.new(*dep) : ::Gem::Dependency.new(dep))
        end
      end
      generator
    end

    attr_reader :development_dependencies, :dependencies, :base
    attr_accessor :version, :changelog
    
    def initialize(dir, name)
      @base = dir
      @name = name
      @dependencies = []
      @development_dependencies = []
      @version = Version::INITIAL_VERSION
      @changelog = Changelog::DEFAULT_FILE
    end

    def write
      write_gemspec
      write_gemfile
      write_version
      write_changelog
      write_rakefile
      write_tumbler_config
      sh 'git init'
      initial_commit
    end

    def initial_commit
      sh 'git init'
      sh 'git add .'
      sh 'git commit -a -m"Initial commit"'
      sh "git tag #{@version}"
    end

    def gemfile_file
      File.join(@base, 'Gemfile')
    end

    def config_file
      File.join(@base, 'Tumbler')
    end

    def init_version
      return unless @version
      File.open(@version.file, "w") {|f| f.puts @version.value.to_s} unless File.exist?(@version.file)
    end

    def init_changelog
      return unless @changelog
      File.open(@changelog.file, "w") {|f| f << ''} unless File.exist?(@changelog.file)
    end

    def write_version
      File.open(File.join(@base, Version::DEFAULT_FILE), 'w') {|f| f << @version }
    end
    
    def write_gemfile
      File.open(gemfile_file, 'w') {|f| f << generate_gemfile }
    end

    def write_rakefile
      FileUtils.cp(template_path('Rakefile'), @base)
    end

    def write_gemspec
      File.open(File.join(@base, "#{@name}.gemspec"), 'w') {|f| f << generate_gemspec }
    end

    def write_changelog
      File.open(File.join(@base, @changelog), 'w') {|f| f << '' } if @changelog
    end

    def write_tumbler_config
      File.open(config_file, 'w') {|f| f << generate_tumbler_conf}
    end

    def git_email
      sh('git config user.email').strip rescue 'user.email'
    end

    def git_name
      sh('git config user.name').strip rescue 'user.name'
    end

    def github_user
      sh('git config github.user').strip rescue 'github.user'
    end

    def template_path(path)
      File.join(File.dirname(__FILE__), '..', '..', 'template', path)
    end

    def generate_tumbler_conf
      template = ERB.new(File.read(template_path('generic.Tumbler.erb')))
      template.result(binding)
    end

    def generate_gemfile
      template = ERB.new <<-EOF
source :rubygems

<% @dependencies.each do |dep|%>gem <%=dep.name.inspect%>, <%=dep.requirement.to_s.inspect%><%="\n"%><% end %>
group(:development) do
<% development_dependencies.each do |dep|%>  gem <%=dep.name.inspect%>, <%=dep.requirement.to_s.inspect%><%="\n"%><% end %>
end
      EOF
      template.result(binding)
    end

    def generate_gemspec
      template = ERB.new(File.read(template_path('generic.gemspec.erb')))
      template.result(binding)
    end
  end
end