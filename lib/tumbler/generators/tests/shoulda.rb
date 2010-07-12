HELPER=<<-TEST
require 'test/unit'
require 'shoulda'
require File.expand_path("/../lib/#{name}.rb",File.dirname(__FILE__))

class Test::Unit::TestCase
end
TEST

FLUNK=<<-FAIL
require File.expand_path('helper.rb',File.dirname(__FILE__))

class Test#{constant_name} < Test::Unit::TestCase
  should "fail" do
    flunk "i flunked"
  end
end
FAIL

def setup_test
  create_file generate_path('test/helper.rb'), HELPER
  create_file generate_path("test/#{name}_test.rb"), FLUNK
end