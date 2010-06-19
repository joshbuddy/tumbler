require File.join(File.dirname(__FILE__),'teststrap')

context "Cli" do
  setup { `rm -rf /tmp/test/icles` }
  context "shows the help" do
    setup { capture(:stdout) { Tumbler::Cli.start(['-h']) } }
    asserts_topic.matches  %r{tumbler name \[options\]}
    asserts_topic.matches  %r{Update existing application}
    asserts_topic.matches  %r{Set the version number}
    asserts_topic.matches  %r{Set the CHANGELOG file}
    asserts_topic.matches  %r{set root path}
  end

  context "generates at designated root" do
    setup { capture(:stdout) { Tumbler::Cli.start(['icles', '-r=/tmp/test/']) } }
    asserts_topic.matches %r{icles successfully generated!}
    asserts("in the right path") { File.exists?('/tmp/test/icles/') }
  end

end