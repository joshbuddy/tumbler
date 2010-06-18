$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'tumbler'
Tumbler.use_rake_tasks

task 'tumbler:preflight' do
  Rake::Task["spec"].invoke
end

require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts ||= []
  t.spec_opts << "--options" << "spec/spec.opts"
  t.spec_files = FileList['spec/**/*_spec.rb']
end
