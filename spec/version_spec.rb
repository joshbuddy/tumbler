require 'spec/spec_helper'

describe 'Tumbler#version' do
  it "should read the current version" do
    create_app('test', :version => '0.1.2') { |app|
      app.version.to_s.should == '0.1.2'
    }
  end

  it "should bump the current version by minor" do
    create_app('test', :version => '0.1.2') { |app|
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      app.bump_and_push(:minor)
      app.version.to_s.should == '0.2.0'
      app.tags.should include('0.2.0')
    }
  end

  it "should bump the current version by tiny" do
    create_app('test', :version => '0.1.2') { |app|
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      app.bump_and_push(:tiny)
      app.version.to_s.should == '0.1.3'
    }
  end

  it "should bump the current version by major" do
    create_app('test', :version => '0.1.2') { |app|
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      app.bump_and_push(:major)
      app.version.to_s.should == '1.0.0'
    }
  end

  it "should bump the current version by major" do
    create_app('test', :version => '0.1.2') { |app|
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      app.bump_and_push(:major)
      app.version.to_s.should == '1.0.0'
    }
  end

  it "should not let you tag the same version twice" do
    create_app('test', :version => '0.1.2') { |app|
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      app.bump_and_push(:major)
      app.version.to_s.should == '1.0.0'
      proc {app.tag_and_push(:major)}.should raise_error
      
    }
  end

end