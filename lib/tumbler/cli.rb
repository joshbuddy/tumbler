require 'optparse'

module Tumbler
  class CLI
    def self.run(args)
      CLI.new(args).run
    end

    def initialize(args)
      @options = {
        :changelog => Manager::Changelog::DEFAULT_FILE,
      }
      parser.parse!(args)
    end

    def parser
      OptionParser.new do |opts|
        opts.banner = "Usage: tumbler name [options]"

        opts.separator ""
        opts.separator "Options:"

        opts.on("-cVALUE", "--changelog=VALUE", "Set changelog file") do |v|
          @options[:changelog] = v
        end

        opts.on("-u", "--update", "Update existing application") do |v|
          @options[:update] = nil
        end

        opts.on("-nc", "--no-changelog", "Disable changelog") do |v|
          @options[:changelog] = nil
        end

        opts.on("-vVALUE", "--version=VALUE", "Set version file") do |v|
          @options[:version] = v
        end

        opts.on("-nv", "--no-version", "Disable version") do |v|
          @options[:version] = nil
        end

        opts.on("-vNAME", "--name=NAME", "Set gem name") do |v|
          @options[:name] = v
        end

        opts.on_tail("-h", "--help", "Show this help message.") { puts opts; exit }
      end
    end

    def run
      app_name = ARGV.first

      if app_name.nil?
        raise 'You must supply an application name.'
      elsif @options.key?(:update)
        Tumbler::Updater.new(app_name, @options).update
      elsif File.exist?(app_name)
        raise "There is already a directory named #{app_name}"
      else
        FileUtils.mkdir_p(app_name)
        Tumbler::Generate.app(app_name, app_name, @options).write
      end

      puts "Gem '#{app_name}' generated successfully!"
    end

  end
end