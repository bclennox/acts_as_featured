module MilesAhead
  module ActsAsFeatured
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      # Designates an attribute on this model to indicate "featuredness," where
      # only one record within a given scope may be featured at a time.
      #
      # Pass in the name of the attribute and an options hash:
      #
      # * <tt>:scope</tt> - If given, designates the scope in which this model is featured. This would typically be a <tt>belongs_to</tt> association.
      # * <tt>:create_scope</tt> - If <tt>true</tt>, creates a named scope using the name of the attribute given here. If it's a symbol, creates a named scope using that symbol.
      #
      #    class Project < ActiveRecord::Base
      #      # no two Projects will ever have their @featured attributes set simultaneously
      #      acts_as_featured :featured
      #    end
      #
      #    class Photo < ActiveRecord::Base
      #      # each account gets a favorite photo
      #      belongs_to :account
      #      acts_as_featured :favorite, :scope => :account
      #    end
      #
      #    class Article < ActiveRecord::Base
      #      # creates a named scope called Article.featured to return the featured article
      #      acts_as_featured :main, :create_scope => :featured
      #    end
      def acts_as_featured(attribute, options = {})
        cattr_accessor :featured_attribute
        cattr_accessor :featured_attribute_scope
        
        self.featured_attribute = attribute
        self.featured_attribute_scope = options[:scope] || false
        
        if scope_name = options[:create_scope]
          scope_name = attribute if scope_name === true
          scope scope_name, where(attribute => true).limit(1)
        end
        
        before_save :remove_featured_from_other_records
        after_save :add_featured_to_first_record
        before_destroy :add_featured_to_first_record_if_featured
      end
    end
    
    private
      
      # <tt>before_save</tt> callback: If we're designating this record to be
      # featured, we should clear that status on other records before saving this one.
      def remove_featured_from_other_records
        if scope && send(featured_attribute)
          # I hope I find a better way to do this
          scope.update_all(["#{featured_attribute} = ?", false], "id != #{id || 0}")
        end
      end

      # <tt>after_save</tt> callback. If this save will result in no featured, just
      # make the first record featured.
      def add_featured_to_first_record
        if scope && scope.count(:conditions => { featured_attribute => true }) == 0
          scope.first.update_attribute(featured_attribute, true)
        end
      end

      # <tt>before_destroy</tt> callback. If we destroy the featured, make the first
      # unfeaturedmain the featured. If this was the last record, don't do anything.
      def add_featured_to_first_record_if_featured
        if scope && send(featured_attribute) && scope.count > 1
          new_main = scope.find(:first, :conditions => { featured_attribute => false })
          new_main.update_attribute(featured_attribute, true) unless new_main.nil?
        end
      end

      def featured_attribute
        @featured_attribute ||= self.class.featured_attribute
      end
      
      # Either the model class or the scope given to acts_as_featured (probably a
      # belongs_to association).
      def scope
        association = self.class.featured_attribute_scope
        @scope ||= if association
          send(association).try(self.class.to_s.underscore.pluralize)
        else
          self.class
        end
      end
  end
end
