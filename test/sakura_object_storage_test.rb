require 'test/unit'
require 'net/http'
require 'yaml'

require 'sakura_object_storage'

class SakuraObjectStorageTest < Test::Unit::TestCase

  @conf   = nil
  @target = nil

  def setup
    @conf = YAML.load(File.read('test/test_config.yml'))
    @target = SakuraObjectStorage::Storage.new(
      @conf['bucket_name'],
      @conf['api_key'],
      @conf['api_secret_key']
    )
  end

  def teardown
  end

  # 疎通確認
  test 'should create a instance.' do
    assert_equal @conf['bucket_name'], @target.bucket_name
    assert_equal @conf['api_key'], @target.api_key
    assert_equal @conf['api_secret_key'], @target.api_secret_key
  end

  # 認証ヘッダ生成ロジック確認
  test 'authorization header' do
    now_date = DateTime.now.httpdate

    header_without_md5_and_type =
      'AWS ' + @conf['api_key'] + ":" +
      Base64.encode64(OpenSSL::HMAC.digest('sha1', @conf['api_secret_key'], 
        "GET\n" +                    # HTTP-VERB
        "\n" +                       # Content-MD5
        "\n" +                       # Content-Type
        "#{now_date}\n" +            # Date
        "/#{@conf['bucket_name']}/"  # CanonicalizedResource
      ))
    assert_equal header_without_md5_and_type, @target.authorization_header('GET', '/', now_date)
  end

  # バケットからオブジェクト一覧を取得できること(空のはず)
  test 'get_list_objects should get object-list from bucket.' do
    result = @target.get_object_list
    assert_kind_of Hash, result
    assert_equal @conf['bucket_name'], result[:name]
    assert_equal 1000, result[:max_keys]
    assert_empty result[:contents]
    assert !result[:is_truncated]
    assert !result.has_key?(:prefix)
    assert !result.has_key?(:marker)
  end

  # 不正なバケット名でアクセスしたとき
  test 'get_list_objects called with not-exist bucket_name should be returned nil.' do
    @conf['bucket_name'] = 'not-exist-bucket'
    @target = SakuraObjectStorage::Storage.new(
      @conf['bucket_name'],
      @conf['api_key'],
      @conf['api_secret_key']
    )
    not_exist = @target.get_object_list
    assert_nil not_exist
    assert_kind_of Net::HTTPNotFound, @target.last_response
    assert_equal 'Not Found', @target.last_response.message, @target.last_response
  end

  # バケットにオブジェクトを作成できること
  test 'put_object should store an object to bucket.' do
    before_object_list = @target.get_object_list
    assert_empty before_object_list[:contents]

    new_object = 'TEST DATA' + DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    new_object_name = 'new_object'

    result = @target.put_object(new_object_name, new_object, new_object.size)
    assert result, "#{@target.last_response}"

    after_object_list = @target.get_object_list
    assert_equal 1, after_object_list[:contents].size

    assert_kind_of Hash, after_object_list[:contents][0]
    assert_equal new_object_name, after_object_list[:contents][0][:key]
    assert_equal new_object.size, after_object_list[:contents][0][:size]
    assert after_object_list[:contents][0].has_key?(:etag)
    assert after_object_list[:contents][0].has_key?(:storage_class)

    assert_kind_of Hash, after_object_list[:contents][0][:owner]
    assert_equal @conf['bucket_name'], after_object_list[:contents][0][:owner][:display_name]
    assert after_object_list[:contents][0][:owner].has_key?(:id)

    assert @target.delete_object(new_object_name)
  end

  # バケットからオブジェクトを取得できること
  test 'get_object should return a object-image on bucket.' do
    new_object = 'TEST DATA' + DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    new_object_name = 'new_object_for_get_object_test'

    assert @target.put_object(new_object_name, new_object, new_object.size)

    object_image = @target.get_object(new_object_name)
    assert_equal new_object, object_image

    assert @target.delete_object(new_object_name)
  end

  # バケットに存在しないオブジェクトを取得しようとしたとき
  test 'get_object called with not-exist_object should be returned false.' do
    assert_empty @target.get_object_list[:contents]

    not_exist = @target.get_object('not exist object')
    assert !not_exist
    assert_kind_of Net::HTTPNotFound, @target.last_response
    assert_equal 'Object Not Found', @target.last_response.message
  end

  # バケットからオブジェクトを削除できること
  test 'delete_object should delete an object from bucket.' do
    delete_target = 'TEST DATA' + DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    delete_target_name = 'delete_target'

    assert @target.put_object(delete_target_name, delete_target, delete_target.size)

    result = @target.delete_object(delete_target_name)
    assert result, "#{@target.last_response}"
  end

  test 'object_info should get an object information.' do
    new_object = 'TEST DATA' + DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    new_object_name = 'new_object_for_get_object_info_test'
    assert @target.put_object(new_object_name, new_object, new_object.size)

    result = @target.object_info(new_object_name)
    assert_kind_of Net::HTTPSuccess, result
    assert result.key?('etag')
    assert result.key?('last-modified')

    assert @target.delete_object(new_object_name)
  end

  test 'object_info called with not-exist object should returned nil.' do
    assert_nil @target.object_info('not exist object')
    assert_kind_of Net::HTTPNotFound, @target.last_response, @target.last_response
  end
end
