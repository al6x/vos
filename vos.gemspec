# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vos/version'

Gem::Specification.new do |gem|
  gem.name          = "vos"
  gem.version       = Vos::VERSION
  gem.authors       = ["Alexander Presber"]
  gem.email         = ["post@momolog.info"]
  gem.description   = %q{Fork of https://github.com/alexeypetrushin/vos}
  gem.summary       = %q{Virtual Operating System}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
