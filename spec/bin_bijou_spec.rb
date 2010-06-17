require 'spec/spec_helper'

describe 'bin/tumbler' do
  before(:each) do
    @bin = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'tumbler'))
    @target = temp_dir('tmp')
  end

  after(:each) do
    FileUtils.rm_rf @target
    $".delete "tumbler/gemspec.rb" # we need to delete this so each gemspec can be generated fresh
  end

  context 'creation' do
    it "should generate an app" do
      Dir.chdir(@target) {`bundle exec ruby #{@bin} test_gem`}
      $?.should == 0
      tumbler = Tumbler.load(File.join(@target, 'test_gem'))
      tumbler.version.to_s.should == '0.0.0'
      tumbler.bundler.dependencies.first.name.should == 'tumbler'
      tumbler.bundler.dependencies.first.requirements_list.should == ['>= 0']
      tumbler.bundler.dependencies.first.groups.should == [:development]
    end
  end
  
  context 'upgrading' do
    before(:each) do
      Dir.chdir(@target) {`bundle exec ruby #{@bin} rails`}
    end
    
    it "should do nothing on a normal existing tumbler app" do
      tumbler = Tumbler.load(File.join(@target, 'rails'))
      version_file = File.read(tumbler.version.file)
      changelog_file = File.read(tumbler.changelog.file)
      gemfile_file = File.read(tumbler.gemfile_path)
      gemspec_file = File.read(tumbler.gemspec_path)
      Dir.chdir(@target) {`bundle exec ruby #{@bin} rails -u`}
      $?.should == 0
      version_file.should == File.read(tumbler.version.file)
      changelog_file.should == File.read(tumbler.changelog.file)
      gemfile_file.should == File.read(tumbler.gemfile_path)
      gemspec_file.should == File.read(tumbler.gemspec_path)
    end

    it "should work from inside the directory" do
      tumbler = Tumbler.load(File.join(@target, 'rails'))
      version_file = File.read(tumbler.version.file)
      changelog_file = File.read(tumbler.changelog.file)
      gemfile_file = File.read(tumbler.gemfile_path)
      gemspec_file = File.read(tumbler.gemspec_path)
      Dir.chdir("#{@target}/rails") {`bundle exec ruby #{@bin} . -u --name rails`}
      $?.should == 0
      version_file.should == File.read(tumbler.version.file)
      changelog_file.should == File.read(tumbler.changelog.file)
      gemfile_file.should == File.read(tumbler.gemfile_path)
      gemspec_file.should == File.read(tumbler.gemspec_path)
    end

    it "should not work if the directory and gemspec mismatch and you don't supply a name" do
      tumbler = Tumbler.load(File.join(@target, 'rails'))
      FileUtils.mv("#{@target}/rails/rails.gemspec", "#{@target}/rails/notrails.gemspec")
      Dir.chdir(@target) {`bundle exec ruby #{@bin} rails -u`}
      $?.exitstatus.should == 1
    end

  end
end
