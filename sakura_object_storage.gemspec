$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sakura_object_storage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sakura_object_storage"
  s.version     = SakuraObjectStorage::VERSION
  s.authors     = ["Kentarou Mamiya"]
  s.email       = ["kmamiya@logicalrabbit.jp"]
  s.homepage    = "http://logicalrabbit.jp/"
  s.summary     = "Summary of SakuraObjectStorage (Not writing yet)."
  s.description = "Description of SakuraObjectStorage (Not writing yet)."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
end
