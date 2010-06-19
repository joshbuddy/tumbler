require File.join(File.dirname(__FILE__),'teststrap')

context "Cli" do
  setup { @test_dir = temp_dir('test') }
  setup { FileUtils.rm_rf @test_dir }
  teardown { FileUtils.rm_rf @test_dir }

  context "shows the help" do
    setup { capture(:stdout) { Tumbler::Cli.start(['-h']) } }
    asserts_topic.matches  %r{tumbler name \[options\]}
    asserts_topic.matches  %r{Update existing application}
    asserts_topic.matches  %r{Set the version number}
    asserts_topic.matches  %r{Set the CHANGELOG file}
    asserts_topic.matches  %r{set root path}
  end

  context "generates" do
    context "the app" do
      setup do
        capture(:stdout) { Tumbler::Cli.start(['test_gem',"-r=#{@test_dir}"]) }
        Tumbler.load(File.join(@test_dir, 'test_gem'))
      end
      asserts("$?") { $? }.equals 0
      asserts("version") { topic.version.to_s }.equals '0.0.0'
      asserts("tumbler") { topic.bundler.dependencies.first.name }.equals 'tumbler'
      asserts(">=0") { topic.bundler.dependencies.first.requirements_list }.equals ['>= 0']
      asserts("development") { topic.bundler.dependencies.first.groups }.equals [:development]
    end

    context "at designated root" do
      setup { capture(:stdout) { Tumbler::Cli.start(['agem', "-r=#{@test_dir}"]) } }
      asserts_topic.matches %r{agem successfully generated!}
      asserts("in the right path") { File.exists? File.join(@test_dir,'agem') }
    end

  end

  context "upgrades" do
    setup { capture(:stdout) { Tumbler::Cli.start(['rails', "-r=#{@test_dir}"]) } }

    context "does nothing on a normal existing tumbler app" do
      setup do
        @tumbler = Tumbler.load(File.join(@test_dir, 'rails'))
        @version = File.read @tumbler.version.file
        @changelog = File.read @tumbler.changelog.file
        @gemfile = File.read @tumbler.gemfile_path
        @gemspec = File.read @tumbler.gemspec_path
      end
      setup { capture(:stdout) { Tumbler::Cli.start(['rails', '-u', "-r=#{@test_dir}"]) } }
      asserts("$?") { $? }.equals 0
      asserts("version") { File.read(@tumbler.version.file) == @version }
      asserts("changelog") { File.read(@tumbler.changelog.file) == @changelog }
      asserts("gemfile") { File.read(@tumbler.gemfile_path) == @gemfile }
      asserts("gemspec") { File.read(@tumbler.gemspec_path) == @gemspec }
    end

    context "should not work if the directory and gemspec mismatch and you don't supply a name" do
      setup do
        FileUtils.mv("#{@test_dir}/rails/rails.gemspec", "#{@test_dir}/rails/notrails.gemspec")
      end
      asserts "exit status" do 
        capture(:stdout) { Tumbler::Cli.start(['rails', '-u',"-r=#{@test_dir}"]) }
      end.raises RuntimeError
    end
  end


end
