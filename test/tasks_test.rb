require File.join(File.dirname(__FILE__),'teststrap')

context "Tasks" do
  setup { ENV['RUBYLIB'] = File.expand_path(File.join(__DIR__, '..', 'lib')) }

  context "should gem.build" do
    setup { @tumbler, @dir, @remote_dir = create_app }
    teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
    setup { @tumbler.gem.build }
    asserts("gem exists") { File.exist?("#{@tumbler.base}/pkg/test-0.0.0.gem") }
  end

  context "version bumping" do

    context "shouldn't write a new tag" do
      setup { @tumbler, @dir, @remote_dir = create_app }
      teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
      setup { @tumbler.bump_and_commit(:minor) }
      asserts("has tag") { @tumbler.tags }.equals ['0.0.0']
    end

    context "should increment the locally stored version" do
      setup { @tumbler, @dir, @remote_dir = create_app }
      teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
      setup { @tumbler.bump_and_commit(:minor) ; @tumbler.reload }
      asserts("has right version") { @tumbler.version.to_s }.equals '0.1.0'
    end

    context "should successfully push after a bump" do
      setup { @tumbler, @dir, @remote_dir = create_app }
      teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
      setup do
        Tumbler::Gem.any_instance.stubs(:push).once.returns(true)
        @tumbler.bump_and_commit(:minor)
        @tumbler.tag_and_push
        @tumbler.reload
      end
      asserts("has right version") { @tumbler.version.to_s }.equals '0.1.0'
      asserts("has right tags") { @tumbler.tags }.equals %w(0.0.0 0.1.0)
    end

    context "shouldn't commit the changed changelog on a simple bump" do
      setup { @tumbler, @dir, @remote_dir = create_app }
      teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
      setup { @tumbler.bump_and_commit(:minor) }
      asserts("git status") { @tumbler.sh('git status') }.matches %r{modified:\s+CHANGELOG}
    end

  end

  context "version bumping & pushing" do
    context "should create a nice changelog" do
      setup { @tumbler, @dir, @remote_dir = create_app }
      teardown { FileUtils.rm_rf @dir ; FileUtils.rm_rf @remote_dir }
      setup do
        Tumbler::Gem.any_instance.stubs(:push).times(4).returns(true)
        @tumbler.sh 'touch test1; git add test1; git commit test1 -m"Added test1"'
        @tumbler.bump_and_push(:minor)
        @tumbler.sh 'touch test2; git add test2; git commit test2 -m"Added test2"'
        @tumbler.sh 'touch test2-1; git add test2-1; git commit test2-1 -m"Added test2-1"'
        @tumbler.bump_and_push(:minor)
        @tumbler.sh 'touch test3; git add test3; git commit test3 -m"Added test3"'
        @tumbler.bump_and_push(:minor)
        @tumbler.sh 'touch test4; git add test4; git commit test4 -m"Added test4"'
        @tumbler.bump_and_push(:minor)
        @tumbler.reload
        File.read(@tumbler.changelog.file)
      end
      asserts_topic.matches %r{== 0\.4\.0\s+\* Added test4 \(.*?\)\n\n==}
      asserts_topic.matches %r{== 0\.3\.0\s+\* Added test3 \(.*?\)\n\n==}
      asserts_topic.matches %r{== 0\.2\.0\s+\* Added test2-1 \(.*?\)\n\* Added test2 \(.*?\)\n\n==}
      asserts_topic.matches %r{== 0\.1\.0\s+\* Added test1 \(.*?\)\n\n$}
    end
  end

end
