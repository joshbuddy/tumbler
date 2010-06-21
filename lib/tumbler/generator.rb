module Tumbler
  module Generator
    include Runner

    # Returns the root for this thor class (also aliased as destination root).
    def destination_root(*paths)
      File.join(@destination_stack.last, paths)
    end

    def generate_path(*path)
      File.join(options[:root],name,path)
    end

    def generate_project
      generate_version unless options[:version].strip == 'none'
      generate_changelog unless options[:changelog].strip == 'none'
      directory('templates/project/', generate_path)
      template('templates/generic.rb.tt',generate_path("lib/#{name}.rb"))
      generate_gemfile
      generate_gemspec
      generate_tumbler
    end

    def constant_name
      result = name.split('_').map{|p| p.capitalize}.join
      result = result.split('-').map{|q| q.capitalize}.join('::') if result =~ /-/
      result
    end

    def generate_version
      @version = options[:version] || Manager::Version::INITIAL_VERSION
      template('templates/version.rb.tt',generate_path("lib/#{name}/version.rb"))
    end

    def generate_changelog
      create_file generate_path(options[:changelog])
    end

    def generate_dependencies
      dependencies, development_dependencies = [], [::Gem::Dependency.new('tumbler')]
      options[:dependencies].split(',').each { |dep| dependencies << ::Gem::Dependency.new(*Array(dep)) } if options[:dependencies]
      options[:development_dependencies].split(',').each { |dep| development_dependencies << ::Gem::Dependency.new(*Array(dep)) } if options[:development_dependencies]
      [dependencies, development_dependencies]
    end

    def generate_gemspec
      template('templates/generic.gemspec.tt',generate_path("#{name}.gemspec"))
    end

    def generate_gemfile
      @dependencies, @development_dependencies = generate_dependencies
      template('templates/Gemfile.tt',generate_path('Gemfile'))
    end

    def generate_tumbler
      template('templates/Tumbler.tt',generate_path('Tumbler'))
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


  end
end
