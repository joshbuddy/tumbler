HELPER=<<-TEST
require File.expand_path("/../lib/#{name}.rb",File.dirname(__FILE__))
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end
TEST

FLUNK=<<-FAIL
require File.expand_path('helper.rb',File.dirname(__FILE__))

describe "#{constant_name}" do
  it "fails" do
    fail "i flunked"
  end
end
FAIL

def setup_test
  create_file generate_path('test/helper.rb'), HELPER
  create_file generate_path("test/#{name}_test.rb"), FLUNK
end