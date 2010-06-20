require 'tumbler/manager/changelog'
require 'tumbler/manager/version'

module Tumbler
  class Manager
    include Runner
    include Informer

    Change = Struct.new(:hash, :author, :summary)

    attr_reader :base, :version, :changelog, :gem, :name
    attr_accessor :noop

    def default_version_file
      File.join('lib', name, 'version.rb')
    end

    def default_changelog_file
      Changelog::DEFAULT_FILE
    end

    def gem_name(name)
      @name = name
    end

    def bundler
      @definition ||= Bundler::Dsl.evaluate(gemfile_path)
    end

    def config_path
      File.join(@base, 'Tumbler')
    end

    def gemfile_path
      File.join(@base, 'Gemfile')
    end

    def gemspec_path
      File.join(@base, "#{@name}.gemspec")
    end

    def lockfile_path
      File.join(@base, 'Gemfile.lock')
    end

    def version_file(file = default_version_file, &block)
      @version = Manager::Version.new(self)
      @version.filename(file)
      @version.instance_eval(&block) if block
      @version.reload
      @version
    end

    def use_gem(&block)
      @gem.instance_eval(block)
    end

    def changelog_file(file = default_changelog_file, &block)
      @changelog = Changelog.new(self)
      @changelog.filename(file)
      @changelog.instance_eval(&block) if block
      @changelog
    end

    def reset
      @version = nil
      @changelog = nil
    end

    def bump_and_commit(field)
      guard_clean
      inform "Bumping & committing" do
        @changelog.update if @changelog
        bump(field)
        @changelog.write_version_header if @changelog
      end
    end

    def tag_and_push
      inform "Tagging & pushing" do
        @changelog.commit if @changelog && !clean?
        guard_clean
        guard_already_tagged
        tag
        push
        @gem.push
      end
    end

    def bump_and_push(field)
      inform "Bumping & pushing" do
        revert_on_error do
          bump_and_commit(field)
          tag_and_push
        end
      end
    end

    def current_revision
      sh('git show --pretty=format:%H').split(/\n/)[0].strip
    end

    def revert_on_error
      current_ref = current_revision
      begin
        yield
      rescue
        inform "Undoing commit"
        sh "git reset --hard #{current_ref}"
        raise
      end
    end

    def guard_clean
      clean? or raise("There are files that need to be committed first.")
    end

    def guard_already_tagged
      sh('git tag').split(/\n/).include?(@version.to_s) and raise("This tag has already been committed to the repo.")
    end

    def bump(level)
      from = @version.to_s
      inform "Bumping from #{from} by #{level}" do
        @version.bump(level)
        @version.commit(from)
      end
    end

    def clean?
      sh("git ls-files -dm").split("\n").size.zero?
    end

    def push
      inform "Pushing commit & tags" do
        sh "git push --all"
        sh "git push --tags"
      end
    end

    def tag
      inform "Tagging version #{@version.to_s}" do
        sh "git tag #{@version.to_s}"
      end
    end

    def tags
      sh('git tag').split(/\n/)
    end

    def reload
      reset
      @gem = Gem.new(self)
      instance_eval(File.read(config_path), config_path, 1)
    end

    def latest_changes
      changes = sh("git log --pretty=format:'%h (%aN) %s' --no-color #{@version}..HEAD").
        scan(/([a-f0-9]{7}) \((.*?)\) (.*)$/).
        map{|line| Change.new(line[0], line[1], line[2])}
    end

    private
      def initialize(base)
        @base = base
        reload
        @noop = true if ENV['DRY'] == '1'
      end
  end
end