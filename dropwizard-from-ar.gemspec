# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Bryan Duxbury"]
  gem.email         = ["bryan.duxbury@gmail.com"]
  gem.description   = "A tool for generating Java database models from Ruby ActiveRecord definitions"
  gem.summary       = "A tool for generating Java database models from Ruby ActiveRecord definitions"
  gem.homepage      = "https://github.com/rayokota/dropwizard-from-ar"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "dropwizard-from-ar"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.0"

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "artii"
  gem.add_runtime_dependency "linguistics"
  gem.add_runtime_dependency "orderedhash"
end
