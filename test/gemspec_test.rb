require File.join(File.dirname(__FILE__),'teststrap')

context "GemspecHelper" do
  setup { @dir, @app = create_bare_app('test') }
  setup { @helper = Tumbler::GemspecHelper.new(@app) }
  teardown { FileUtils.rm_rf(@dir) }

  asserts(:name).equals 'test'
  asserts(:version).equals '0.0.0'
  asserts(:files).equivalent_to ["CHANGELOG", "Gemfile", "Rakefile", "Tumbler", "lib/test.rb", "lib/test/version.rb", "test.gemspec"]
  asserts(:date).equals Time.new.strftime("%Y-%m-%d")
  
  context "inject_dependencies" do
    setup do
      spec = Gem::Specification.new
      File.open("#{@app.base}/Gemfile", 'a') {|f| f.puts "gem 'test', '>= 0.0.5'"}
      @app.reload
      @helper.inject_dependencies(spec) ; spec
    end
    asserts(:runtime_dependencies).equals [Gem::Dependency.new('test', '>= 0.0.5')]
    asserts(:development_dependencies).equals [Gem::Dependency.new('tumbler', '>= 0', :development)]
  end
end
