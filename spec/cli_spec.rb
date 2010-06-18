require 'spec/spec_helper'

describe "Cli" do
  before { `rm -rf /tmp/test/icles` }
  it "shows the help" do
    output = capture(:stdout) { Tumbler::Cli.start(['-h']) }
    output.should =~ %r{tumbler name \[options\]}
    output.should =~ %r{Update existing application}
    output.should =~ %r{Set the version number}
    output.should =~ %r{Set the CHANGELOG file}
    output.should =~ %r{set root path}
  end

  it "generates at designated root" do
    output = capture(:stdout) { Tumbler::Cli.start(['icles', '-r=/tmp/test/']) }
    File.exists?('/tmp/test/icles/').should be_true
  end

end