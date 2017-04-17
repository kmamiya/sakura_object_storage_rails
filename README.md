# SakuraObjectStorage
The Ruby on Rails Plugin for Sakura Cloud Object Storage access.

* Not Amazon S3 compartible, writing for only Sakura Cloud Object storage.
* Support the following functions.
  1. get object list. (GET /)
  1. get an object. (GET  with object_name)
  1. put an object. (PUT)
  1. delete an object. (DELETE)
  1. get only an object-information. (HEAD, get only ETag and LastModified.)


THIS IS UNDER CONSTRUCTION!


## Usage

1. Create a bucket on your Sakura Cloud Object storage.
1. Keep API-Key and API-Secret-Key.

```ruby
require 'sakura_object_storage'

instance = SakuraObjectStorage.new( bucket_name, api_key, api_secret_key )
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sakura_object_storage'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sakura_object_storage
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

