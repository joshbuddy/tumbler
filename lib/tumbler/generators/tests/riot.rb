TESTSTRAP=<<-TEST
require 'riot'
require File.expand_path("/../lib/#{name}.rb",File.dirname(__FILE__))
TEST

FLUNK=<<-FAIL
require File.expand_path('teststrap.rb',File.dirname(__FILE__))

context "#{name} gem" do
  asserts("i flunked") { false }
end
FAIL

def setup_test
  create_file generate_path('test/teststrap.rb'), TESTSTRAP
  create_file generate_path("test/#{name}_test.rb"), FLUNK
end