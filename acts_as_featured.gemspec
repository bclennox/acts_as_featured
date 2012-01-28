# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_featured/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_featured"
  s.version     = ActsAsFeatured::VERSION
  s.authors     = ["Brandan Lennox"]
  s.email       = ["brandan@bclennox.com"]
  s.homepage    = "https://github.com/bclennox/acts_as_featured"
  s.date        = "2012-01-28"
  s.summary     = %q{Designate a Rails model attribute as unique within a scope}
  s.description = %q{Designates an attribute on this model to indicate "featuredness," where only one record within a given scope may be featured at a time.}

  s.rubyforge_project = "acts_as_featured"

  s.files = %w{
    acts_as_featured.gemspec
    Gemfile
    MIT-LICENSE
    README.markdown

    lib/acts_as_featured.rb
    lib/acts_as_featured/version.rb
  }

  s.test_files = %w{
    spec/acts_as_featured_spec.rb
    spec/models.rb
    spec/spec_helper.rb
  }

  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 3.0.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "sqlite3-ruby"
end
