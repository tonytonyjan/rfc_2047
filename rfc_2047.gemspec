# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'new_rfc_2047'
  spec.version = '1.0.0'
  spec.licenses = ['MIT']
  spec.summary = 'An implementation of RFC 2047'
  spec.description = 'An implementation of RFC 2047'
  spec.author = 'Jian Weihang'
  spec.files = Dir['lib/**/*.rb']
  spec.email = 'tonytonyjan@gmail.com'
  spec.homepage = 'https://github.com/tonytonyjan/rfc_2047'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake', '~> 13'
end
