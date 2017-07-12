# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ld/version'

Gem::Specification.new do |spec|
  spec.name          = "ld"
  spec.version       = Ld::VERSION
  spec.authors       = ["Liu Dong"]
  spec.email         = ["chuangye201012@163.com"]

  spec.summary       = %q{Practical small tools.}
  spec.description   = %q{For the sake of efficiency, The Module is my name abbreviations LD, Basically has the following Class.}
  spec.homepage      = "https://github.com/18810625123/ld"
  spec.license       = "MIT"

  spec.add_dependency 'terminal-table', '~> 1.8'
  spec.add_dependency 'spreadsheet'
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "hpricot", "~> 0.8.6"
end
