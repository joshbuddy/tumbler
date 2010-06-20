module Tumbler
  class Gem
    include Runner
    include Informer
    
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
      inform "Pushing #{built_gem_path}" do
        sh("gem push #{built_gem_path}")
      end
    end

    def install
      build
      inform "Installing #{built_gem_path}" do
        exec("sudo gem install #{built_gem_path}")
      end
    end

    def spec_path
      "#{@manager.name}.gemspec"
    end

    def build
      inform "Building #{built_gem_path}" do
        sh("bundle exec gem build #{spec_path}")
        Dir.chdir(base) { 
          FileUtils.mkdir_p('pkg')
          FileUtils.mv(built_gem_base, 'pkg')
        }
      end
    end
  end
end