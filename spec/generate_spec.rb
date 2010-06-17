require 'spec/spec_helper'

describe Tumbler::Generate do

  after(:each) do
    $".delete "tumbler/gemspec.rb" # we need to delete this so each gemspec can be generated fresh
  end

  it "should suppress changelog creation if disabled" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem', :changelog => nil).write
      File.exist?(File.join(test_dir, "CHANGELOG")).should be_false
    end
  end

  it "should generate a gemspec" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem').write
      spec = Gem::Specification.load("#{test_dir}/mygem.gemspec")
      spec.dependencies.should == [Gem::Dependency.new('tumbler', '>=0', :development)]
    end
  end

  it "should generate a Rakefile" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem').write
      File.exist?("#{test_dir}/Rakefile").should be_true
    end
  end

  it "should accept an extra dependency" do
    temp_dir('test2') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem', :dependencies => 'eventmachine').write
      spec = Gem::Specification.load("#{test_dir}/mygem.gemspec")
      spec.dependencies.size.should == 2
      spec.dependencies.should include(Gem::Dependency.new('tumbler', '>=0', :development))
      spec.dependencies.should include(Gem::Dependency.new('eventmachine', '>=0', :runtime))
    end
  end

  it "should accept an extra dependency with a version" do
    temp_dir('test2') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem', :dependencies => [['eventmachine', '>=1.0.0']]).write
      spec = Gem::Specification.load("#{test_dir}/mygem.gemspec")
      spec.dependencies.size.should == 2
      spec.dependencies.should include(Gem::Dependency.new('tumbler', '>=0', :development))
      spec.dependencies.should include(Gem::Dependency.new('eventmachine', '>=1.0.0', :runtime))
    end
  end
end
