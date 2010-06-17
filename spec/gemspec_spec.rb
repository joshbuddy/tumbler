require 'spec/spec_helper'

describe Tumbler::GemspecHelper do
  before(:each) do
    @dir, @app = create_bare_app('test')
    @helper = Tumbler::GemspecHelper.new(@app)
  end
  
  after(:each) do
    FileUtils.rm_rf(@dir)
  end
  
  it "should have a name" do
    @helper.name.should == 'test'
  end

  it "should have a version number" do
    @helper.version.should == '0.0.0'
  end

  it "should have files" do
    @helper.files.should == ["CHANGELOG", "Gemfile", "Rakefile", "Tumbler", "lib/VERSION", "test.gemspec"]
  end

  it "should have a date" do
    @helper.date.should == Time.new.strftime("%Y-%m-%d")
  end

  it "should inject_dependencies" do
    spec = Gem::Specification.new
    File.open("#{@app.base}/Gemfile", 'a') {|f| f.puts "gem 'test', '>= 0.0.5'"}
    @app.reload
    @helper.inject_dependencies(spec)
    spec.runtime_dependencies.should == [Gem::Dependency.new('test', '>= 0.0.5')]
    spec.development_dependencies.should == [Gem::Dependency.new('tumbler', '>= 0', :development)]
  end

end
