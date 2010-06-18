require 'thor/group'

module Tumbler
  class Cli < Thor::Group
    include Thor::Actions

    def self.banner; "tumbler name [options]"; end

    desc "Generates a new gem project"

    argument :name, :desc => "name of your awesome gem"

    class_option :changelog, :desc => 'Set the CHANGELOG file',       :aliases => '-c', :default => nil,   :type => :string
    class_option :update,    :desc => 'Update existing application',  :aliases => '-u', :default => false, :type => :boolean
    class_option :version,   :desc => 'Set the version number',       :aliases => '-v', :default => nil,   :type => :string
    class_option :root,      :desc => 'set root path',                :aliases => '-r', :default => '.',   :type => :string
    def setup_gem
      path = File.join options[:root], name
      case
      when options[:update] then Tumbler::Updater.new(path, options).update
      when File.exist?(path) then raise("Directory path #{path} already exists!")
      else FileUtils.mkdir_p(path) ; Tumbler::Generate.app(path, name, options).write
      end
      say "Gem #{name} successfully generated!", :green
    end
  end
end
