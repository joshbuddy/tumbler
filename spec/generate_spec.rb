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

  it "should generate the mygem directory" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem', :changelog => nil).write
      File.exist?(File.join(test_dir, "lib", "mygem")).should be_true
    end
  end
  
  it "should generate the mygem.rb file" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'my_gem', :changelog => nil).write
      path = File.join(test_dir, "lib", 'my_gem.rb')
      File.exist?(path).should be_true
      path.should match_in_file %r{module MyGem #:nodoc}
      path.should match_in_file %r{require 'my_gem/version'}
    end
  end
  
  it "should generate the gem constant correctly with -" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'my-gem', :changelog => nil).write
      File.join(test_dir, 'lib','my-gem','version.rb').should match_in_file(/My::Gem/)
    end
  end

  it "should generate the gem constant correctly with _" do
    temp_dir('test') do |test_dir|
      Tumbler::Generate.app(test_dir, 'my_gem', :changelog => nil).write
      File.join(test_dir, 'lib','my_gem','version.rb').should match_in_file(/MyGem/)
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
      spec.dependencies.should include(Gem::Dependency.new('tumbler', '>=0', :development))
      spec.dependencies.should include(Gem::Dependency.new('eventmachine', '>=0', :runtime))
      spec.dependencies.size.should == 2
    end
  end

  it "should accept an extra dependency with a version" do
    temp_dir('test2') do |test_dir|
      Tumbler::Generate.app(test_dir, 'mygem', :dependencies => [['eventmachine', '>=1.0.0']]).write
      spec = Gem::Specification.load("#{test_dir}/mygem.gemspec")
      spec.dependencies.should include(Gem::Dependency.new('tumbler', '>=0', :development))
      spec.dependencies.should include(Gem::Dependency.new('eventmachine', '>=1.0.0', :runtime))
      spec.dependencies.size.should == 2
    end
  end
end
