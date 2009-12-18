module MilesAhead
  module ActsAsFeatured
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_featured(attribute, options = {})
        cattr_accessor :featured_attribute
        cattr_accessor :featured_attribute_scope
        
        self.featured_attribute = attribute
        self.featured_attribute_scope = options[:scope] || false
        
        if scope_name = options[:named_scope]
          scope_name = attribute if scope_name === true
          named_scope scope_name, :conditions => { attribute => true }, :limit => 1
        end
        
        before_save :remove_featured_from_other_records
        after_save :add_featured_to_first_record
        before_destroy :add_featured_to_first_record_if_featured
      end
    end
    
    private
      
      # If we're designating this record to be the main, we should
      # clear that status on other records before saving this one.
      def remove_featured_from_other_records
        if scope && self.send(featured_attribute)
          scope.update_all(["#{featured_attribute} = ?", false])
        end
      end

      # If this save will result in no main, just make the first
      # record the main.
      def add_featured_to_first_record
        if scope && scope.count(:conditions => { featured_attribute => true }) == 0
          scope.first.update_attribute(featured_attribute, true)
        end
      end

      # If we destroy the main, make the first non-main the main.
      # If this was the last record, don't do anything
      def add_featured_to_first_record_if_featured
        if self.send(featured_attribute) && scope && scope.count > 1
          new_main = scope.find(:first, :conditions => { featured_attribute => false })
          new_main.update_attribute(featured_attribute, true) unless new_main.nil?
        end
      end

      def featured_attribute
        @featured_attribute ||= self.class.featured_attribute
      end
      
      def scope
        @scope ||= if association
          send(association).try(self.class.to_s.underscore.pluralize)
        else
          self.class
        end
      end

      def association
        @association ||= self.class.featured_attribute_scope
      end
  end
end