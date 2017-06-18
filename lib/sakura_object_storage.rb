require 'openssl'
require 'net/http'
require 'rexml/parsers/sax2parser'
require 'base64'

require 'sakura_object_storage/list_bucket_result_parser'

module SakuraObjectStorage

  class Storage
    attr_reader :bucket_name, :api_key, :api_secret_key, :last_response

    API_URL = 'b.sakurastorage.jp'

    def initialize(bucket_name, api_key, api_secret_key)
      @bucket_name    = bucket_name
      @api_key        = api_key
      @api_secret_key = api_secret_key
    end

    def http_session
      uri = URI.parse("https://#{@bucket_name}.#{API_URL}")
      session = Net::HTTP.new(uri.host, uri.port)
      session.use_ssl = true

      return session
    end

    def object_path(object_name)
      return '/' + URI.encode_www_form_component(object_name)
    end

    def authorization_header(http_method, path_and_query, header_date, content_md5 = '', content_type = '')
      canonicalized_resource = "/#{@bucket_name}#{path_and_query}"
      string_token =
        "#{http_method}\n" +
        "#{content_md5}\n" +
        "#{content_type}\n" +
        "#{header_date}\n" +
        canonicalized_resource

      return "AWS #{@api_key}:" +
        Base64.encode64(OpenSSL::HMAC.digest(
          'sha1', @api_secret_key, string_token
        ))
    end

    def get_object_list
      header_date = DateTime.now.httpdate
      path = '/'
      session = self.http_session
      @last_response = session.get(path, {
        'Date'          => header_date,
        'Authorization' => self.authorization_header('GET', path, header_date)
      })
      if @last_response.kind_of? Net::HTTPSuccess
        return ListBucketResultParser.new(@last_response.body).parse
      else
        return nil
      end
    end

    def put_object(name, data, size, use_md5_check = false, content_type = 'binary/octet-stream')
      header_date = DateTime.now.httpdate
      path = self.object_path(name)

      session = self.http_session
      @last_response = session.put(path, data, {
        'Date'          => header_date,
        'Authorization' => self.authorization_header('PUT', path, header_date, '', content_type),
        'Content-Length' => size.to_s,
        'Content-Type'   => content_type
      })
      return @last_response.kind_of? Net::HTTPSuccess
    end

    def get_object(name)
      header_date = DateTime.now.httpdate
      path = self.object_path(name)

      session = self.http_session
      @last_response = session.get(path, {
        'Date'          => header_date,
        'Authorization' => self.authorization_header('GET', path, header_date),
        'Accept'        => '*/*'
      })
      return (@last_response.kind_of? Net::HTTPSuccess) ? @last_response.body : nil
    end

    def delete_object(name)
      header_date = DateTime.now.httpdate
      path = self.object_path(name)

      session = self.http_session
      @last_response = session.delete(path, {
        'Date'          => header_date,
        'Authorization' => self.authorization_header('DELETE', path, header_date)
      })
      return @last_response.kind_of? Net::HTTPSuccess
    end

    def object_info(name)
      header_date = DateTime.now.httpdate
      path = self.object_path(name)

      session = self.http_session
      @last_response = session.head(path, {
        'Date'          => header_date,
        'Authorization' => self.authorization_header('HEAD', path, header_date)
      })
      return ( @last_response.kind_of? Net::HTTPNotFound )? nil : @last_response
    end
  end
end
