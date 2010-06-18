require 'spec/spec_helper'

describe Tumbler do
  before(:all) do
    ENV['RUBYLIB'] = File.expand_path(File.join(__DIR__, '..', 'lib'))
  end

  it "should gem.build" do
    create_app do |app|
      app.gem.build
      File.exist?("#{app.base}/pkg/test-0.0.0.gem").should be_true
    end
  end

  context "version bumping" do
    it "shouldn't write a new tag" do
      create_app do |app|
        app.bump_and_commit(:minor)
        app.tags.should == ['0.0.0']
      end
    end
  
    it "should increment the locally stored version" do
      create_app do |app|
        app.bump_and_commit(:minor)
        app.reload
        app.version.to_s.should == '0.1.0'
      end
    end
  
    it "should successfully push after a bump" do
      create_app do |app|
        Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
        app.bump_and_commit(:minor)
        app.tag_and_push
        app.reload
        app.version.to_s.should == '0.1.0'
        app.tags.should == %w(0.0.0 0.1.0)
      end
    end

    it "shouldn't commit the changed changelog on a simple bump" do
      create_app do |app|
        app.bump_and_commit(:minor)
        app.sh('git status').should match(/modified:\s+CHANGELOG/)
      end
    end

  end
  
  context "version bumping & pushing" do
    it "should create a nice changelog" do
      create_app do |app|
        Tumbler::Gem.any_instance.stubs(:push).times(4).returns(true)
        app.sh 'touch test1; git add test1; git commit test1 -m"Added test1"'
        app.bump_and_push(:minor)
        app.sh 'touch test2; git add test2; git commit test2 -m"Added test2"'
        app.sh 'touch test2-1; git add test2-1; git commit test2-1 -m"Added test2-1"'
        app.bump_and_push(:minor)
        app.sh 'touch test3; git add test3; git commit test3 -m"Added test3"'
        app.bump_and_push(:minor)
        app.sh 'touch test4; git add test4; git commit test4 -m"Added test4"'
        app.bump_and_push(:minor)
        app.reload
        changelog = File.read(app.changelog.file)
        changelog.should match(/== 0\.4\.0\s+\* Added test4 \(.*?\)\n\n==/)
        changelog.should match(/== 0\.3\.0\s+\* Added test3 \(.*?\)\n\n==/)
        changelog.should match(/== 0\.2\.0\s+\* Added test2-1 \(.*?\)\n\* Added test2 \(.*?\)\n\n==/)
        changelog.should match(/== 0\.1\.0\s+\* Added test1 \(.*?\)\n\n$/)
      end
    end
  end
  
  #
  #  @app.bump_and_commit(:minor)
  #  @app.tag_and_push
  #end

end