module Tumbler
  module Generator
    include Runner

    def destination_root(path='')
      File.join options[:root], name, path
    end

    def generate_project
      generate_version if options[:version]
      generate_changelog if options[:changelog]
      directory(File.join(options[:root],name))
      #template('templates/generic.rb.tt',destination_root("lib/#{name}.rb}"))
      generate_gemfile
      generate_gemspec
      generate_tumbler
    end

    def generate_version
      version = options[:version] || Manager::Version::INITIAL_VERSION
      template('templates/version.rb.tt',destination_root("lib/#{name}/version.rb"))
    end

    def generate_changelog
      create_file("templates/#{options[:changelog]}")
    end

    def generate_dependencies
      dependencies, development_dependencies = [], [::Gem::Dependency.new('tumbler')]
      options[:dependencies].each { |dep| dependencies << ::Gem::Dependency.new(*Array(dep)) } if options[:dependencies]
      options[:development_dependencies].each { |dep| development_dependencies << ::Gem::Dependency.new(*Array(dep)) } if options[:development_dependencies]
      [dependencies, development_dependencies]
    end

    def generate_gemspec
      template('template/generic.gemspec.tt',destination_root("#{name}.gemspec"))
    end

    def generate_gemfile
      @dependencies, @development_dependencies = generate_dependencies
      template('templates/Gemfile.tt',destination_root('Gemfile'))
    end

    def generate_tumbler
      template('templates/Tumbler.tt',destination_root('Tumbler'))
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