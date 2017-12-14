
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruboty-fastly/version"

Gem::Specification.new do |spec|
  spec.name          = "ruboty-fastly"
  spec.version       = RubotyFastly::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["sorah@cookpad.com"]

  spec.summary       = %q{Ruboty plugin for Fastly chat-ops}
  spec.homepage      = "https://github.com/sorah/ruboty-fastly"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruboty"
  spec.add_dependency "fastly"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
