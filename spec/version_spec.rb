require 'spec/spec_helper'

describe 'Tumbler#version' do
  it "should read the current version" do
    create_app('test', :version => '0.1.2') { |tumbler|
      tumbler.version.to_s.should == '0.1.2'
    }
  end

  it "should bump the current version by minor" do
    create_app('test', :version => '0.1.2') { |tumbler|
      puts "File.read(tumbler.version.file) #{File.read(tumbler.version.file)}"
      tumbler.bump_and_push(:minor)
      tumbler.version.to_s.should == '0.2.0'
      tumbler.tags.should include('0.2.0')
    }
  end

  it "should bump the current version by tiny" do
    create_app('test', :version => '0.1.2') { |tumbler|
      tumbler.bump_and_push(:tiny)
      tumbler.version.to_s.should == '0.1.3'
    }
  end

  it "should bump the current version by major" do
    create_app('test', :version => '0.1.2') { |tumbler|
      tumbler.bump_and_push(:major)
      tumbler.version.to_s.should == '1.0.0'
    }
  end

  it "should bump the current version by major" do
    create_app('test', :version => '0.1.2') { |tumbler|
      tumbler.bump_and_push(:major)
      tumbler.version.to_s.should == '1.0.0'
    }
  end

  it "should not let you tag the same version twice" do
    create_app('test', :version => '0.1.2') { |tumbler|
      tumbler.bump_and_push(:major)
      tumbler.version.to_s.should == '1.0.0'
      proc {tumbler.tag_and_push(:major)}.should raise_error
      
    }
  end

end