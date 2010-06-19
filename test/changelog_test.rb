require File.join(File.dirname(__FILE__),'teststrap')

context "Manager::Changelog" do
  setup { $".delete "tumbler/gemspec.rb" }
  teardown { $".delete "tumbler/gemspec.rb" } # we need to delete this so each gemspec can be generated fresh

  context "generates changelog" do
    setup { @tumbler, @dir, @test_dir = create_app('test') }
    teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @test_dir }
    setup do
      @tumbler.sh 'touch file1'
      @tumbler.sh 'git add file1'
      @tumbler.sh 'git commit file1 -m"added file1"'
      @tumbler.sh 'touch file2'
      @tumbler.sh 'git add file2'
      @tumbler.sh 'git commit file2 -m"added file2"'
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      @tumbler.bump_and_push(:tiny)
      @tumbler
    end
    asserts("correct version") { topic.version.to_s }.equals '0.0.1'
    asserts("adds to changelog file") { File.read(topic.changelog.file) }.matches %r{== 0\.0\.1\s+\* added file2 \(.*?, [a-f0-9]{7}\)\s+\* added file1 \(.*?, [a-f0-9]{7}\)}
  end

  context "should not perform any changelog activity when the option isn't specified" do
    setup { @tumbler, @dir, @test_dir = create_app('test', :changelog => nil) }
    teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @test_dir }
    setup do
      @tumbler.sh 'touch file1'
      @tumbler.sh 'git add file1'
      @tumbler.sh 'git commit file1 -m"added file1"'
      @tumbler.sh 'touch file2'
      @tumbler.sh 'git add file2'
      @tumbler.sh 'git commit file2 -m"added file2"'
      Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
      @tumbler.bump_and_push(:tiny)
      @tumbler
    end
    asserts("correct version") { topic.version.to_s }.equals '0.0.1'
    asserts("CHANGELOG exist") { File.exist?(File.join(topic.base, 'CHANGELOG')) }.not!
  end

  context "should rollback the entire set of commits when the remote is unreachable" do
    setup { @tumbler, @dir, @test_dir = create_app('test', :changelog => nil,:remote => 'ssh://ijustmadethisupisadomain.com/what_you_say.git') }
    teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @test_dir }
    setup do
      @tumbler.sh 'touch file1'
      @tumbler.sh 'git add file1'
      @tumbler.sh 'git commit file1 -m"added file1"'
      @tumbler.sh 'touch file2'
      @tumbler.sh 'git add file2'
      @tumbler.sh 'git commit file2 -m"added file2"'
      @current_rev = @tumbler.current_revision
      @tumbler
    end
    asserts("raises error") { topic.bump_and_push(:tiny) }.raises RuntimeError
    asserts("commit revision") { @tumbler.sh('git log').split(/\n/)[0] == "commit #{@current_rev}" }
  end
end