require 'rubygems'
require 'tempfile'
require 'fileutils'
require 'riot'
require 'mocha'
require 'fakeweb'
FakeWeb.allow_net_connect = false

#Dir.glob(File.join(File.dirname(__FILE__),'macros')) { |file|  require file }

$LOAD_PATH << File.basename(__FILE__)
$LOAD_PATH << File.join(File.basename(__FILE__), '..', 'lib')
require 'tumbler'

Tumbler::Gem.any_instance.stubs(:install).raises
Tumbler::Gem.any_instance.stubs(:push).raises


Riot.reporter = Riot::DotMatrixReporter
class Riot::Situation

  def create_app(name='test', opts={})
    @dir = temp_dir(name)
    @remote_dir = temp_dir("remote-#{name}.git")
    Tumbler::Generate.app(@dir, name, opts).write
    Dir.chdir(@remote_dir) { `git --bare init` }
    remote = opts[:remote] || "file://#{@remote_dir}"
    Dir.chdir(@dir) {
      `git remote add origin #{remote}`
      `git push origin master`
    }
    [Tumbler::Manager.new(@dir), @dir, @remote_dir]
  end

  def create_bare_app(name, opts = {})
    dir = temp_dir(name)
    Tumbler::Generate.app(dir, name, opts).write
    tumbler = Tumbler::Manager.new(dir)
    [dir, tumbler]
  end

  def temp_dir(name)
    dir = File.join(Dir.tmpdir, rand(10000).to_s, "#{Process.pid}-#{name}")
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
    if block_given?
      begin
        yield dir
      ensure
        FileUtils.rm_rf(dir)
      end
    else
      dir
    end
  end

end

class Riot::Context

end

class Object
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

end
