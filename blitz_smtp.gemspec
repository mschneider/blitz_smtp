# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blitz_smtp/version'

Gem::Specification.new do |gem|
  gem.name          = "blitz_smtp"
  gem.version       = BlitzSMTP::VERSION
  gem.authors       = ["Maximilian Schneider"]
  gem.email         = ["mail@maximilianschneider.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{BlitzSMTP implements RFC2920 (Command Pipelining)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
