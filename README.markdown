Acts as Featured
================

Designates an attribute on this model to indicate "featuredness," where only one record within a given scope may be featured at a time.

Pass in the name of the attribute and an options hash:

* `:scope` - If given, designates the scope in which this model is featured. This would typically be a `belongs_to` association.
* `:create_scope` - If `true`, creates a named scope using the name of the attribute given here. If it's a symbol, creates a named scope using that symbol.

Examples:

    class Project < ActiveRecord::Base
      # no two Projects will ever have their @featured attributes set simultaneously
      acts_as_featured :featured
    end

    class Photo < ActiveRecord::Base
      # each account gets a favorite photo
      belongs_to :account
      acts_as_featured :favorite, :scope => :account
    end

    class Article < ActiveRecord::Base
      # creates a named scope called Article.featured to return the featured article
      acts_as_featured :main, :create_scope => :featured
    end

Running Tests
-------------

It's RSpec:

    rspec spec/acts_as_featured_spec.rb

Make sure you run `bundle install` to get the development dependencies first.

License
-------

See LICENSE.txt.
