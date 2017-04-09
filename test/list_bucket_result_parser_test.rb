require 'test_helper'

class ListBucketResultParser::Test < ActiveSupport::TestCase
  test'shoud_create_a_instance' do
    xml_src = '<?xml version="1.0" encoding="UTF-8"?><start></start>'
    target = ListBucketResultParser.new(xml_src)

    assert_equal xml_src, target.xml_src
  end
end
