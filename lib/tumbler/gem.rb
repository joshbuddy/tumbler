module Tumbler
  class Gem
    include Runner

    def initialize(manager)
      @manager = manager
    end

    def base
      @manager.base
    end

    def built_gem_base
      "#{@manager.name}-#{@manager.version.to_s}.gem"
    end

    def built_gem_path
      File.join('pkg', built_gem_base)
    end

    def push
      build
      sh("gem push #{built_gem_path}")
    end

    def install
      build
      exec("sudo gem install #{built_gem_path}")
    end

    def spec_path
      "#{@manager.name}.gemspec"
    end

    def build
      sh("bundle exec gem build #{spec_path}")
      Dir.chdir(base) { 
        FileUtils.mkdir_p('pkg')
        FileUtils.mv(built_gem_base, 'pkg')
      }
    end
  end
end