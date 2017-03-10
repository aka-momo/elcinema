# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elcinema/version'

Gem::Specification.new do |spec|
  spec.name          = 'elcinema'
  spec.version       = Elcinema::VERSION
  spec.authors       = ['Mohamed Diaa', 'Ramy Aboul Naga']
  spec.email         = ['mohamed.diaa27@gmail.com', 'ramy.naga@gmail.com']

  spec.summary       = 'Elcinema is a gem for exploring theaters from elcinema.com'
  spec.homepage      = 'https://github.com/mohameddiaa27/elcinema'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://github.com/mohameddiaa27/elcinema'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json',     '~> 2.0'
  spec.add_dependency 'nokogiri', '~> 1.7'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'byebug',  '~> 9.0'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
end
