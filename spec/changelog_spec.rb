require 'spec/spec_helper'

describe Tumbler::Manager::Changelog do

  after(:each) do
    $".delete "tumbler/gemspec.rb" # we need to delete this so each gemspec can be generated fresh
  end

  it "should generate a changelog" do
    create_app('test') { |tumbler|
      tumbler.sh 'touch file1'
      tumbler.sh 'git add file1'
      tumbler.sh 'git commit file1 -m"added file1"'
      tumbler.sh 'touch file2'
      tumbler.sh 'git add file2'
      tumbler.sh 'git commit file2 -m"added file2"'
      tumbler.bump_and_push(:tiny)
      tumbler.version.to_s.should == '0.0.1'
      changelog = File.read(tumbler.changelog.file)
      changelog.should match(/== 0\.0\.1\s+\* added file2 \(.*?, [a-f0-9]{7}\)\s+\* added file1 \(.*?, [a-f0-9]{7}\)/)
    }
  end

  it "should not perform any changelog activity when the option isn't specified" do
    create_app('test', :changelog => nil) { |tumbler|
      tumbler.sh 'touch file1'
      tumbler.sh 'git add file1'
      tumbler.sh 'git commit file1 -m"added file1"'
      tumbler.sh 'touch file2'
      tumbler.sh 'git add file2'
      tumbler.sh 'git commit file2 -m"added file2"'
      tumbler.bump_and_push(:tiny)
      tumbler.version.to_s.should == '0.0.1'
      File.exist?(File.join(tumbler.base, 'CHANGELOG')).should be_false
    }
  end
  
  it "should rollback the entire set of commits when the remote is unreachable" do
    create_app('test', :changelog => nil, :remote => 'ssh://ijustmadethisupisadomain.com/what_you_say.git') { |tumbler|
      tumbler.sh 'touch file1'
      tumbler.sh 'git add file1'
      tumbler.sh 'git commit file1 -m"added file1"'
      tumbler.sh 'touch file2'
      tumbler.sh 'git add file2'
      tumbler.sh 'git commit file2 -m"added file2"'
      current_rev = tumbler.current_revision
      proc {tumbler.bump_and_push(:tiny)}.should raise_error
      tumbler.sh('git log').split(/\n/)[0].should == "commit #{current_rev}"
    }
  end

end
