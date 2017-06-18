# SakuraObjectStorage
The Ruby Plugin for Sakura Cloud Object Storage access.

* Not Amazon S3 compartible, writing for only Sakura Cloud Object storage.
* Support the following functions.
  1. get object list. (GET /)
  1. get an object. (GET  with object_name)
  1. put an object. (PUT)
  1. delete an object. (DELETE)
  1. get only an object-information. (HEAD, get only ETag and LastModified.)
* NOT support the following function.
  1. multipart uploading for large object (over 4GiB) ... It is need?? ( I don't need, maybe. )

## Usage

1. Create a bucket on your Sakura Cloud Object storage.
1. Keep API-Key and API-Secret-Key.

```ruby
require 'sakura_object_storage'

instance = SakuraObjectStorage::Storage.new( bucket_name, api_key, api_secret_key )

# Create an object.
body = 'object contents.'
instance.put_object('object name', body, body.size)

# Get list
list = instance.get_object_list()[:contents]

# Get an object 
obj = instance.get_object('object name')

# Get an information of object
info = instance.get_object_info('object name')
etag = info['etag']
last_modified = info['last-modified']

# Delete an object
instance.delete_object('object name')
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sakura_object_storage', git: 'https://github.com/kmamiya/sakura_object_storage_ruby.git'
```

And then execute:
```bash
$ bundle
```

## Support page (Japanese)

http://logicalrabbit.jp/sakura-object-storage

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
