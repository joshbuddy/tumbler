require 'rubygems'
require 'erb'

module Tumbler
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

    attr_reader :development_dependencies, :dependencies, :base, :name
    attr_accessor :version, :changelog

    def initialize(dir, name)
      @base = dir
      @name = name
      @dependencies = []
      @development_dependencies = []
      @version = Manager::Version::INITIAL_VERSION
      @changelog = Manager::Changelog::DEFAULT_FILE
    end

    def constant_name
      result = @name.split('_').map{|p| p.capitalize}.join
      result = result.split('-').map{|q| q.capitalize}.join('::') if result =~ /-/
      result
    end

    def write
      write_gemspec
      write_gemfile
      write_version(@version)
      write_file
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
    
    def gemspec_file
      File.join(@base, "#{@name}.gemspec")
    end

    def config_file
      File.join(@base, 'Tumbler')
    end

    def version_path
      File.join(@base, 'lib', @name, 'version.rb')
    end

    def rb_path
      File.join(@base, 'lib', "#{@name}.rb")
    end
    
    def write_changelog
      File.open(File.join(@base, @changelog), 'w') {|f| f << '' } if @changelog
    end
    
    def write_rakefile
      FileUtils.cp(template_path('Rakefile'), @base)
    end

    def write_file
      copy_template('generic.rb.erb', :to => rb_path)
    end
    
    def write_version(version)
      copy_template('version.rb.erb', :to => version_path, :binding => binding)
    end

    def write_gemfile
      copy_template('Gemfile.erb', :to => gemfile_file)
    end

    def write_gemspec
      copy_template('generic.gemspec.erb', :to => gemspec_file)
    end

    def write_tumbler_config
      copy_template('Tumbler.erb', :to => config_file)
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
      File.join(File.dirname(__FILE__), '..', 'template', path)
    end

    # copy_template('generic.rb.erb', :to => '/path/to/file')
    def copy_template(template_file, options={})
      FileUtils.mkdir_p(File.dirname(options[:to]))
      template = ERB.new(File.read(template_path(template_file)), 0, '<>')
      contents = template.result(options[:binding] || binding)
      File.open(options[:to], 'w') {|f| f << contents }
    end
  end
end