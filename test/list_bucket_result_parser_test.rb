require 'test-unit'

require 'sakura_object_storage/list_bucket_result_parser'

class ListBucketResultParser::Test < Test::Unit::TestCase
  test'shoud_create_a_instance' do
    xml_src = '<?xml version="1.0" encoding="UTF-8"?><start></start>'
    target = ListBucketResultParser.new(xml_src)

    assert_equal xml_src, target.xml_src
  end
end
