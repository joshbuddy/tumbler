require File.join(File.dirname(__FILE__),'teststrap')

context "Generate" do
  setup { @test_dir = temp_dir('test') }
  teardown { $".delete "tumbler/gemspec.rb" } # we need to delete this so each gemspec can be generated fresh
  teardown{ FileUtils.rm_rf(@test_dir) }

  context "suppress changelog creation if disabled" do
    setup { Tumbler::Generate.app(@test_dir, 'mygem', :changelog => nil).write }
    asserts("has changelog") { File.exist? File.join(@test_dir, "CHANGELOG") }.not!
  end

  context "generate changelog with specified name" do
    setup { Tumbler::Generate.app(@test_dir, 'my_gem', :change_log => 'CHANGES').write }
    asserts("has changes") { File.exists? File.join(@test_dir,'CHANGES') }
  end
  
  context "generate mygem directory" do
    setup { Tumbler::Generate.app(@test_dir, 'mygem').write }
    asserts("dir exists") { File.exist? File.join(@test_dir, "lib", "mygem") }
  end

  context "generate the mygem.rb file" do
    setup do
      Tumbler::Generate.app(@test_dir, 'my_gem').write
      File.join(@test_dir, "lib", 'my_gem.rb')
    end
    asserts("it exists") { File.exist? topic }
    asserts("has module") { File.read(topic) }.matches %r{module MyGem #:nodoc}
    asserts("has require") { File.read(topic) }.matches %r{require 'my_gem/version'\n}
  end

  context "surpress version.rb creation if disabled" do
    setup do
      Tumbler::Generate.app(@test_dir, 'my_gem', :version => nil).write
      File.join(@test_dir, "lib", 'my_gem.rb')
    end
    asserts("exists") { File.exists? topic }
    asserts("module") { File.read topic }.matches %r{module MyGem #:nodoc}
    asserts("version.rb") { File.exists? File.join(@test_dir,'lib/my_gem/version.rb') }.not!
    asserts("require") { File.read(topic) =~ %r{require 'my_gem/version'\n} }.not!
  end

  context "generate the version.rb if specified" do
    setup do
      Tumbler::Generate.app(@test_dir, 'my_gem', :version => '1.0.0').write
      File.join(@test_dir,'lib','my_gem','version.rb')
    end
    asserts("exists") { File.exists? topic }
    asserts("module") { File.read topic }.matches %r{module MyGem #:nodoc}
    asserts("version") { File.read topic }.matches %r{1.0.0}
  end

  context "generate the gem constant correctly with -" do
    setup { Tumbler::Generate.app(@test_dir, 'my-gem').write }
    asserts("My::Gem") { File.read File.join(@test_dir, 'lib','my-gem','version.rb') }.matches %r{My::Gem}
  end

  context "generate the gem constant correctly with _" do
    setup { Tumbler::Generate.app(@test_dir, 'my_gem').write }
    asserts("MyGem") { File.read File.join(@test_dir, 'lib','my_gem','version.rb') }.matches %r{MyGem}
  end

  context "generate a gemspec" do
    setup do
      Tumbler::Generate.app(@test_dir, 'mygem').write
      Gem::Specification.load("#{@test_dir}/mygem.gemspec")
    end
    asserts(:dependencies).equals [Gem::Dependency.new('tumbler', '>=0', :development)]
  end

  context "generate a Rakefile" do
    setup { Tumbler::Generate.app(@test_dir, 'mygem').write }
    asserts("Rakefile") { File.exist?("#{@test_dir}/Rakefile") }
  end

  context "accepts an extra dependency" do
    setup do
      Tumbler::Generate.app(@test_dir, 'mygem', :dependencies => 'eventmachine').write
      Gem::Specification.load("#{@test_dir}/mygem.gemspec")
    end
    asserts(:dependencies).includes Gem::Dependency.new('tumbler', '>=0', :development)
    asserts(:dependencies).includes Gem::Dependency.new('eventmachine', '>=0', :runtime)
    asserts(:dependencies).size 2
  end

  context "accepts an extra dependency with a version" do
    setup do
      Tumbler::Generate.app(@test_dir, 'mygem', :dependencies => [['eventmachine', '>=1.0.0']]).write
      Gem::Specification.load("#{@test_dir}/mygem.gemspec")
    end
    asserts(:dependencies).includes Gem::Dependency.new('tumbler', '>=0', :development)
    asserts(:dependencies).includes Gem::Dependency.new('eventmachine', '>=1.0.0', :runtime)
    asserts(:dependencies).size 2
  end

end
