require File.join(File.dirname(__FILE__),'teststrap')
require 'fakeweb'
FakeWeb.allow_net_connect = false


context "Updater" do
  setup do
    @bin = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'tumbler'))
    @target = '/tmp/test'
    FileUtils.mkdir_p(@target)
    capture(:stdout) { Tumbler::Cli.start(['rails',"-r=#{@target}"]) }
  end
  teardown do
    FileUtils.rm_rf @target
    $".delete "tumbler/gemspec.rb" # we need to delete this so each gemspec can be generated fresh
  end

  context "fetches the version number" do
    setup do
      FakeWeb.register_uri(:get, "http://rubygems.org/api/v1/gems/rails.json", :body => '{ "name": "rails", "info": "Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.", "version": "2.3.5", "version_downloads": 2451, "authors": "David Heinemeier Hansson", "downloads": 134451, "project_uri": "http://rubygems.org/gems/rails", "gem_uri": "http://rubygems.org/gems/rails-2.3.5.gem", "dependencies": { "runtime": [ { "name": "activesupport", "requirements": ">= 2.3.5" } ], "development": [ ] }}')
      File.unlink("#{@target}/rails/lib/rails/version.rb")
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
      File.read("#{@target}/rails/lib/rails/version.rb")
    end
    asserts_topic.matches %r{2\.3\.5}
  end

  context "generates a CHANGELOG" do
    setup do
      File.unlink("#{@target}/rails/CHANGELOG")
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("file exists") { File.exist?("#{@target}/rails/CHANGELOG") }
  end

  context "does not append anything to the Rakefile as it already has the tumbler tasks in it" do
    setup do
      @rakefile = File.read("#{@target}/rails/Rakefile")
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("same rakefile") { @rakefile == File.read("/tmp/test/rails/Rakefile") }
  end

  context "append the Tumbler tasks if they don't already exist" do
    setup do
      File.open("#{@target}/rails/Rakefile", 'w') {|f| f.puts '# Some other rake file'}
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("finds use_rake_tasks once") do
      File.read("#{@target}/rails/Rakefile").scan(/require 'tumbler'\nTumbler\.use_rake_tasks/)
    end.size 1
  end

  context "does not append anything to the gemspec if it already is using tumbler" do
    setup do
      @gemspec = File.read("#{@target}/rails/rails.gemspec")
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("doesn't change") { File.read("#{@target}/rails/rails.gemspec") == @gemspec }
  end

  context "append inject_dependencies if its doesn't exist" do
    setup do
      File.open("#{@target}/rails/Rakefile", 'w') {|f| f.puts '# Some other gemspec file'}
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("finds inject_dependencies once") do
      File.read("#{@target}/rails/rails.gemspec").scan(/tumbler.inject_dependencies/)
    end.size 1
  end

  context "add a Tumbler config file if it doesn't exist" do
    setup do
      File.unlink("#{@target}/rails/Tumbler")
      Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    end
    asserts("adds Tumbler file") { File.exist?("#{@target}/rails/Tumbler") }
  end

end
