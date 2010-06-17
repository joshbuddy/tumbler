require 'callsite'
require 'versionomy'
require 'bundler'

Callsite.activate_kernel_dir_methods

$LOAD_PATH << __DIR__

require 'tumbler/runner'
require 'tumbler/updater'
require 'tumbler/rake_tasks'
require 'tumbler/version'
require 'tumbler/gemspec_helper'
require 'tumbler/changelog'
require 'tumbler/generate'
require 'tumbler/gem'
require 'tumbler/cli'

class Tumbler
  def self.load_version(filename = Version::DEFAULT_FILE)
    File.read(File.join(__DIR__, '..', filename))
  end

  VERSION = Tumbler.load_version

  include Runner
  
  Change = Struct.new(:hash, :author, :summary)
  
  attr_reader :base, :version, :changelog, :gem, :name
  attr_accessor :noop

  def self.use_rake_tasks(name = nil)
    root = File.dirname(Callsite.parse(caller).find{|c| c.filename =~ /Rakefile/}.filename)
    Tumbler::RakeTasks.register(File.expand_path(root), name)
  end

  def self.load(base)
    File.exist?(File.join(base, 'Tumbler')) ? new(base) : nil
  end

  def set_version(version)
    @version = Version.new
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

  def use_version(&block)
    @version = Version.new(self, &block)
  end

  def use_gem(&block)
    @gem.instance_eval(block)
  end

  def use_changelog(&block)
    @changelog = Changelog.new(self, &block)
  end

  def reset
    @version = nil
    @changelog = nil
  end

  def bump_and_commit(field)
    guard_clean
    @changelog.update if @changelog
    bump(field)
    if @changelog
      @changelog.write_version_header
      @changelog.commit
    end
  end

  def tag_and_push
    guard_clean
    guard_already_tagged
    tag
    push
  end

  def bump_and_push(field)
    revert_on_error {
      bump_and_commit(field)
      tag_and_push
    }
  end

  def current_revision
    sh('git show --pretty=format:%H').split(/\n/)[0].strip
  end

  def revert_on_error
    current_ref = current_revision
    begin
      yield
    rescue
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
    @version.bump(level)
    @version.commit(from)
  end

  def clean?
    sh("git ls-files -dm").split("\n").size.zero?
  end

  def push
    sh "git push --all"
    sh "git push --tags"
  end

  def tag
    sh "git tag #{@version.to_s}"
  end

  def commit(msg)
    sh "git commit #{@version.basefile} -m'#{msg}'"
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