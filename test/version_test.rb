require File.join(File.dirname(__FILE__),'teststrap')

context 'Version' do
  setup { @tumbler, @dir, @remote_dir = create_app('test', :version => '0.1.2') }
  setup { Tumbler::Gem.any_instance.stubs(:push).once.returns(true) }
  teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
  asserts("right version") { @tumbler.version.to_s }.equals '0.1.2'

  context "should bump the current version by minor" do
    setup { @tumbler.bump_and_push(:minor) }
    asserts("right version") { @tumbler.version.to_s }.equals '0.2.0'
    asserts("has tags") { @tumbler.tags }.includes '0.2.0'
  end

  context "should bump the current version by tiny" do
    setup { @tumbler.bump_and_push(:tiny) }
    asserts("right version") { @tumbler.version.to_s }.equals '0.1.3'
  end

  context "should bump the current version by major" do
    setup { @tumbler.bump_and_push(:major) }
    asserts("right version") { @tumbler.version.to_s }.equals '1.0.0'
  end

  context "should not let you tag the same version twice" do
    setup { @tumbler.bump_and_push(:major) }
    asserts("right version") { @tumbler.version.to_s }.equals '1.0.0'
    asserts("should fail") { @tumbler.tag_and_push(:major) }.raises ArgumentError
  end

end
