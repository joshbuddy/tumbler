require 'spec_helper'
require 'fakeweb'

describe Tumbler::Updater do
  before(:each) do
    @bin = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'tumbler'))
    @target = temp_dir('tmp')
    Dir.chdir(@target) {`bundle exec ruby #{@bin} rails`}
  end

  after(:each) do
    FileUtils.rm_rf @target
    $".delete "tumbler/gemspec.rb" # we need to delete this so each gemspec can be generated fresh
  end

  it "should fetch the version number" do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://rubygems.org/api/v1/gems/rails.json", :body => '{ "name": "rails", "info": "Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.", "version": "2.3.5", "version_downloads": 2451, "authors": "David Heinemeier Hansson", "downloads": 134451, "project_uri": "http://rubygems.org/gems/rails", "gem_uri": "http://rubygems.org/gems/rails-2.3.5.gem", "dependencies": { "runtime": [ { "name": "activesupport", "requirements": ">= 2.3.5" } ], "development": [ ] }}')
    File.unlink("#{@target}/rails/lib/VERSION")
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.read("#{@target}/rails/lib/VERSION").should == '2.3.5'
  end

  it "should generate a CHANGELOG" do
    File.unlink("#{@target}/rails/CHANGELOG")
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.exist?("#{@target}/rails/CHANGELOG").should be_true
  end
  
  it "should not append anything to the Rakefile as it already has the tumbler tasks in it" do
    rakefile = File.read("#{@target}/rails/Rakefile")
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.read("#{@target}/rails/Rakefile").should == rakefile
  end
  
  it "should append the Tumbler tasks if they don't already exist" do
    File.open("#{@target}/rails/Rakefile", 'w') {|f| f.puts '# Some other rake file'}
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.read("#{@target}/rails/Rakefile").scan(/require 'tumbler'\nTumbler\.use_rake_tasks/).size.should == 1
  end
  
  it "should not append anything to the gemspec if it already is using tumbler" do
    gemspec = File.read("#{@target}/rails/rails.gemspec")
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.read("#{@target}/rails/rails.gemspec").should == gemspec
  end
  
  it "should append inject deps if its not there already" do
    File.open("#{@target}/rails/Rakefile", 'w') {|f| f.puts '# Some other gemspec file'}
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.read("#{@target}/rails/rails.gemspec").scan(/Tumbler::Gemspec.inject_dependencies/).size.should == 1
  end
  
  it "should add a Tumbler config file if its not already there" do
    File.unlink("#{@target}/rails/Tumbler")
    Tumbler::Updater.new("#{@target}/rails", :name => 'rails').update
    File.exist?("#{@target}/rails/Tumbler").should be_true
  end
  
end