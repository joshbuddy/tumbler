require 'thor/group'
require File.join(File.dirname(__FILE__), 'generators','project')

module Tumbler
  class Cli < Thor::Group
    include Thor::Actions
    include Tumbler::Generator::Project
    #self.source_paths << File.expand_path(File.dirname(__FILE__))
    
    def self.banner; "tumbler name [options]"; end
    def self.source_root; File.join(File.dirname(__FILE__),'..'); end
      
    desc "Generates a new gem project"

    argument :name, :desc => "name of your awesome gem"

    class_option :changelog,    :desc => 'Set the CHANGELOG file',       :aliases => '-c', :default => 'CHANGELOG', :type => :string
    class_option :update,       :desc => 'Update existing application',  :aliases => '-u', :default => false,       :type => :boolean
    class_option :version,      :desc => 'Set the version number',       :aliases => '-v', :default => '0.0.0',     :type => :string
    class_option :test,         :desc => 'Generate tests',               :aliases => '-t', :default => nil,         :type => :string
    class_option :root,         :desc => 'set root path',                :aliases => '-r', :default => '.',         :type => :string
    class_option :dependencies, :desc => 'set gem dependencies',         :aliases => '-d', :default => nil,         :type => :string
    def setup_gem
      path = File.join options[:root], name
      case
      when options[:update] then Tumbler::Updater.new(path, options).update
      when File.exist?(path) then raise("Directory path #{path} already exists!")
      else FileUtils.mkdir_p(path) ; generate_project
      end
      say "Gem #{name} successfully generated!", :green
    end
  end
end
