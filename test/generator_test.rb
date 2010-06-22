require File.join(File.dirname(__FILE__),'teststrap')

context "Generator" do
  setup { @test_dir = temp_dir('test') }
  setup { FileUtils.rm_rf @test_dir }
  teardown { $".delete "tumbler/gemspec.rb" } # we need to delete this so each gemspec can be generated fresh

  context "defaults" do
    setup { capture(:stdout) { Tumbler::Cli.start(['my_gem',"-r=#{@test_dir}"]) } }
    asserts("dir exists") { File.exist? File.join(@test_dir, 'my_gem', 'lib', 'my_gem') }
    asserts("CHANGELOG") { File.exist? File.join(@test_dir, 'my_gem', 'CHANGELOG') }

    context "my_gem.rb" do
      setup { File.join(@test_dir, 'my_gem', 'lib', 'my_gem.rb') }
      asserts("my_gem.rb") { File.exist?  topic }
      asserts("has module") { File.read(topic) }.matches %r{module MyGem #:nodoc}
      asserts("has require") { File.read(topic) }.matches %r{require 'my_gem/version'\n}
    end

    context "version.rb" do
      setup { File.join(@test_dir, 'my_gem', 'lib', 'my_gem','version.rb') }
      asserts("exists") { File.exists? topic }
      asserts("module") { File.read topic }.matches %r{module MyGem #:nodoc}
      asserts("version") { File.read topic }.matches %r{0.0.0}
    end

    context "my_gem.gemspec" do
      setup { File.join(@test_dir, 'my_gem', 'my_gem.gemspec') }
      asserts("name") { File.read topic }.matches %r{s.name = "my_gem"}
      asserts("test") { File.read topic }.matches %r{Tumbler::Gemspec.files\(\/\^test\/\)}
      asserts("files") { File.read topic }.matches %r{require_paths = \["lib"\]}
    end

    context "Rakefile" do
      setup { File.join(@test_dir, 'my_gem', 'Rakefile') }
      asserts("require") { File.read topic }.matches %r{require 'tumbler'}
      asserts("rake tasks") { File.read topic }.matches %r{Tumbler.use_rake_tasks}
    end

    context "Gemfile" do
      setup { File.join(@test_dir, 'my_gem', 'Gemfile') }
      asserts("require") { File.read topic }.matches %r{source :rubygems}
      asserts("rake tasks") { File.read topic }.matches %r{gem "tumbler"}
    end

    context "Tumbler" do
      setup { File.join(@test_dir, 'my_gem', 'Tumbler') }
      asserts("gem_name") { File.read topic }.matches %r{gem_name my_gem}
      asserts("version_file") { File.read topic }.matches %r{version_file 'lib/my_gem/version.rb'}
      asserts("changelog") { File.read topic }.matches %r{changelog_file CHANGELOG}
    end

  end

  context "suppress changelog creation if disabled" do
    setup { capture(:stdout) { Tumbler::Cli.start(['new_gem','-c=none', "-r=#{@test_dir}"]) } }
    setup { File.join(@test_dir, 'new_gem', 'Tumbler') }
    asserts("has changelog") { File.exist? File.join(@test_dir,'new_gem', 'CHANGELOG') }.not!
    asserts("changelog") { File.read(topic) =~ %r{changelog_file CHANGELOG} }.not!
  end

  context "generate changelog with specified name" do
    setup { capture(:stdout) { Tumbler::Cli.start(['new_gem','-c=CHANGES', "-r=#{@test_dir}"]) } }
    asserts("has changes") { File.exists? File.join(@test_dir,'new_gem', 'CHANGES') }
  end

  context "surpress version.rb creation if disabled" do
    setup do
      capture(:stdout) { Tumbler::Cli.start(['my_gem','-v=none',"-r=#{@test_dir}"]) }
      @tumbler = File.join(@test_dir, 'my_gem', 'Tumbler')
      File.join(@test_dir, 'my_gem','lib', 'my_gem.rb')
    end
    asserts("exists") { File.exists? topic }
    asserts("module") { File.read topic }.matches %r{module MyGem #:nodoc}
    asserts("version.rb") { File.exists? File.join(@test_dir, 'my_gem','lib', 'my_gem','version.rb') }.not!
    asserts("require") { File.read(topic) =~ %r{require 'my_gem/version'\n} }.not!
    asserts("version_file") { File.read(@tumbler) =~ %r{version_file 'lib/my_gem/version.rb'} }.not!
  end

  context "generate the version.rb if specified" do
    setup do
      capture(:stdout) { Tumbler::Cli.start(['my_gem','-v=1.0.0',"-r=#{@test_dir}"]) }
      File.join(@test_dir,'my_gem','lib','my_gem','version.rb')
    end
    asserts("exists") { File.exists? topic }
    asserts("module") { File.read topic }.matches %r{module MyGem #:nodoc}
    asserts("version") { File.read topic }.matches %r{1.0.0}
  end

  context "generate the gem constant correctly with -" do
    setup { capture(:stdout) { Tumbler::Cli.start(['my-gem','-v=1.0.0',"-r=#{@test_dir}"]) } }
    setup { File.join(@test_dir,'my-gem','lib','my-gem','version.rb') }
    asserts("My::Gem") { File.read topic }.matches %r{My::Gem}
  end

  context "generate the gem constant correctly with _" do
    setup { capture(:stdout) { Tumbler::Cli.start(['my_gem','-v=1.0.0',"-r=#{@test_dir}"]) } }
    setup { File.join(@test_dir,'my_gem','lib','my_gem','version.rb') }
    asserts("My::Gem") { File.read topic }.matches %r{MyGem}
  end

  context "generate dependencies" do

    context "extra dependency" do
      setup do
        capture(:stdout) { Tumbler::Cli.start(['my_gem','-d=eventmachine,hpricot',"-r=#{@test_dir}"]) }
        File.join(@test_dir,'my_gem','Gemfile')
      end
      asserts("gem 'eventmachine") { File.read topic }.matches %r{gem "eventmachine"}
      asserts("gem 'hpricot") { File.read topic }.matches %r{gem "hpricot"}
    end

    context "extra dependency version" do
      setup do
        capture(:stdout) { Tumbler::Cli.start(['my_gem',"-d='eventmachine>=1.0.0'","-r=#{@test_dir}"]) }
        File.join(@test_dir,'my_gem','Gemfile')
      end
      asserts("gem 'eventmachine") { File.read topic }.matches %r{gem "eventmachine", ">=1.0.0"}
    end
  end

end
