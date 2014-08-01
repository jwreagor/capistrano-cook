# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capistrano/chef/version"

Gem::Specification.new do |gem|
  gem.name        = "capistrano-cook"
  gem.version     = Capistrano::Chef::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ['Justin Reagor']
  gem.email       = ['cheapRoc@gmail.com']
  gem.homepage    = "https://github.com/cheapRoc/capistrano-cook"
  gem.summary     = %q{Capistrano 3 support for working with Chef, not replacing it}
  gem.description = %q{Provides easy support for using Capistrano and Chef together}
  gem.license     = 'MIT'

  gem.files         = Dir[*%w(*.md *.gemspec LICENSE Gemfile bin/* lib/**/*.*)]
  gem.test_files    = Dir[*%w(.chef/knife.rb .chef/stickywicket.pem test/**/*.*)]
  gem.executables   = Dir["bin/*"].map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", "~> 3.2.1"
  gem.add_dependency "chef",       "~> 11.12.8"

  gem.add_development_dependency "bundler", "~> 1.6"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "chef-zero"
end

