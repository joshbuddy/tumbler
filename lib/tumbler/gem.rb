module Tumbler
  class Gem
    include Runner

    def initialize(manager)
      @manager = manager
    end

    def base
      @manager.base
    end

    def push
      build
      sh("gem push #{built_gem_path}")
    end

    def built_gem_path
      "#{@manager.name}-#{@manager.version.to_s}.gem"
    end

    def install
      build
      exec("sudo gem install pkg/#{built_gem_path}")
    end

    def spec_path
      "#{@manager.name}.gemspec"
    end

    def build
      sh("bundle exec gem build #{spec_path}")
      sh("mkdir -p pkg")
      sh("mv -f #{built_gem_path} pkg/")
    end
  end
end