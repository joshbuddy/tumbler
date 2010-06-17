require 'net/http'
require 'uri'
require 'json'

class Tumbler
  class Updater
    def initialize(dir, opts = nil)
      @dir = dir
      @name = opts && opts[:name] || File.basename(File.expand_path(dir))
      raise "Couldn't find #{gemspec_path}" unless File.exist?(gemspec_path)
    end

    def update
      upgrade_deps
      upgrade_version
      upgrade_changelog
      upgrade_rakefile
      upgrade_tumbler_config
    end

    def upgrade_tumbler_config
      unless File.exist?(tumbler_config_path)
        Tumbler::Generate.app(@dir, @name).write_tumbler_config
      end
    end

    def upgrade_deps
      if File.exist?(gemfile_path)
        gemspec = File.read(gemspec_path)
        unless gemspec[/add_bundler_dependencies/] || gemspec[/inject_dependencies/]
          @tainted_gemspec = true
          File.open(gemspec_path, 'a') do |g|
            g << <<-HERE_DOC
raise # (see below)

# You probably want to use inject the dependencies using either
# add_bundler_depenedencies or Tumbler::Gemspec.inject_dependencies(spec) (where spec is your Gemspec)
            HERE_DOC
          end
        end
      end
    end

    def upgrade_version
      unless File.exists?(version_path)
        # go to rubygems and get it
        gem_data = JSON.parse(Net::HTTP.get(URI.parse("http://rubygems.org/api/v1/gems/#{URI.escape(@name)}.json")))
        version = gem_data['version']
        File.open(version_path, 'w') {|f| f << version}
      end
    end

    def upgrade_changelog
      unless File.exists?(changelog_path)
        Tumbler::Generate.app(@dir, @name).write_changelog
      end
    end

    def upgrade_rakefile
      create_rakefile and return if !File.exist?(rakefile_path)
      rakefile = File.read(rakefile_path)
      if rakefile !~ /Tumbler.use_rake_tasks/
        File.open(rakefile_path, 'a') {|f| f.puts "\n\n# automatically added Tumbler tasks\n\nrequire 'tumbler'\nTumbler.use_rake_tasks"}
      end
    end

    def rakefile_path
      File.join(@dir, 'Rakefile')
    end

    def tumbler_config_path
      File.join(@dir, 'Tumbler')
    end

    def create_rakefile
      File.open(rakefile_path, 'w') { |f|
        f.puts "require 'tumbler'\nnTumbler.use_rake_tasks"
      }
    end

    def version_path
      File.join(@dir, Version::DEFAULT_FILE)
    end

    def changelog_path
      File.join(@dir, Changelog::DEFAULT_FILE)
    end

    def gemspec_path
      File.join(@dir, "#{@name}.gemspec")
    end

    def gemfile_path
      File.join(@dir, 'Gemfile')
    end
  end
end