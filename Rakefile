$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'tumbler'
Tumbler.use_rake_tasks

# task 'tumbler:preflight' do
#   Rake::Task["spec"].invoke
# end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end