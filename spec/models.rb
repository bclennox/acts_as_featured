# a basic model
class Thingy < ActiveRecord::Base
  acts_as_featured :featured, :create_scope => true
end

# a model that belongs_to another model
class ScopedThingy < ActiveRecord::Base
  belongs_to :thingy_aggregator
  acts_as_featured :featured, :scope => :thingy_aggregator
end
class ThingyAggregator < ActiveRecord::Base
  has_many :scoped_thingies
end

# a model with a default named scope
class DefaultNamedScopeThingy < ActiveRecord::Base
  acts_as_featured :featured, :create_scope => true
end

# a model with a custom named scope
class CustomNamedScopeThingy < ActiveRecord::Base
  acts_as_featured :featured, :create_scope => :special
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  [:thingies, :named_scope_thingies, :default_named_scope_thingies].each do |name|
    create_table name, :force => true do |t|
      t.boolean :featured
    end
  end
  
  create_table :thingy_aggregators, :force => true do |t|
    t.timestamps
  end
  
  create_table :scoped_thingies, :force => true do |t|
    t.belongs_to :thingy_aggregator
    t.boolean :featured
  end
end
ActiveRecord::Migration.verbose = true
