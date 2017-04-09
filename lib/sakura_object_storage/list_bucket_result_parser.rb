require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

class ListBucketResultParser
  attr_accessor :xml_src

  def initialize(xml_src)
    @xml_src = xml_src
  end

  def parse
    listener = Listener.new
    parser = REXML::Parsers::SAX2Parser.new(@xml_src)
    parser.listen(listener)
    parser.parse

    return listener.result
  end

  class Listener
    include REXML::SAX2Listener

    attr_accessor :result

    def initialize
      @list_bucket_result_started = false
      @bucket_name_started = false
      @prefix_started = false
      @marker_started = false
      @max_keys_started = false
      @is_truncated_started = false
      @contents_started = false

      @object_key_started = false
      @last_modified_started = false
      @etag_started = false
      @size_started = false
      @storage_class_started = false
      @owner_started = false

      @owner_id_started = false
      @display_bucket_name_started = false

      @result = Hash.new
      @result[:contents] = Array.new
      @current_content = nil
      @current_owner   = nil
    end

    def start_element(uri, localname, qname, attrs)
      case localname
        when 'ListBucketResult'
          @list_bucket_result_started = true
        when 'Name'
          @bucket_name_started = true if @list_bucket_result_started
        when 'Prefix'
          @prefix_started = true if @list_bucket_result_started
        when 'Marker'
          @marker_started = true if @list_bucket_result_started
        when 'MaxKeys'
          @max_keys_started = true if @list_bucket_result_started
        when 'IsTruncated'
          @is_truncated_started = true if @list_bucket_result_started
        when 'Contents'
          @contents_started = true if @list_bucket_result_started
          @current_content = Hash.new

        when 'Key'
          @object_key_started = true if @contents_started
        when 'LastModified'
          @last_modified_started = true if @contents_started
        when 'ETag'
          @etag_started = true if @contents_started
        when 'Size'
          @size_started = true if @contents_started
        when 'StorageClass'
          @storage_class_started = true if @contents_started
        when 'Owner'
          @owner_started = true if @contents_started
          @current_owner   = Hash.new

        when 'ID'
          @owner_id_started = true if @owner_started
        when 'DisplayName'
          @display_bucket_name_started = true if @owner_started
      end
    end

    def end_element(uri, localname, qname)
      case localname
        when 'ListBucketResult'
          @list_bucket_result_started = false
        when 'Name'
          @bucket_name_started = false
        when 'Prefix'
          @prefix_started = false
        when 'Marker'
          @marker_started = false
        when 'MaxKeys'
          @max_keys_started = false
        when 'IsTruncated'
          @is_truncated_started = false

        when 'Contents'
          @result[:contents] << @current_content
          @current_content = nil
          @contents_started = false

        when 'Key'
          @object_key_started = false
        when 'LastModified'
          @last_modified_started = false
        when 'ETag'
          @etag_started = false
        when 'Size'
          @size_started = false
        when 'StorageClass'
          @storage_class_started = false
        when 'Owner'
          @current_content[:owner] = @current_owner
          @current_owner = nil
          @owner_started = false

        when 'ID'
          @owner_id_started = false
        when 'DisplayName'
          @display_bucket_name_started = false
      end
    end

    def characters(text)
      if @list_bucket_result_started
        @result[:name] = text if @bucket_name_started
        @result[:prefix] = text if @prefix_started
        @result[:marker] = text if @marker_started
        @result[:max_keys] = text.to_i if @max_keys_started
        @result[:is_truncated] = ('true' == text) if @is_truncated_started
        
        @current_content[:key] = text if @object_key_started
        if @last_modified_started
          @current_content[:last_modified] = DateTime.parse(text).new_offset(
            DateTime.now.zone
          )
        end
        @current_content[:etag] = text if @etag_started
        @current_content[:size] = text.to_i if @size_started
        @current_content[:storage_class] = text if @storage_class_started

        @current_owner[:id] = text if @owner_id_started
        @current_owner[:display_name] = text if @display_bucket_name_started
      end
    end
  end
end
