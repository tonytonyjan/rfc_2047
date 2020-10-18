# frozen_string_literal: true

require 'rake/testtask'
require 'rubygems/package_task'

task default: :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/test*.rb']
end

spec = Gem::Specification.load(File.expand_path('rfc_2047.gemspec', __dir__))
Gem::PackageTask.new(spec).define
