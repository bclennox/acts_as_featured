require File.dirname(__FILE__) + '/spec_helper'

describe MilesAhead::ActsAsFeatured do
  def featured(model)
    model.find_all_by_featured(true)
  end
  
  describe "unscoped" do
    before(:each) do
      3.times { Thingy.create(:featured => false) }
    end

    after(:each) do
      Thingy.delete_all
    end
    
    it 'should leave featured status alone when saving the currently featured thingy' do
      originally_featured = Thingy.create(:featured => true)
      featured(Thingy).first.should == originally_featured
      originally_featured.save
      featured(Thingy).first.should == originally_featured
    end

    it 'should remove featured status from the currently featured thingy when setting it on another thingy' do
      originally_featured = Thingy.create(:featured => true)
      will_be_featured = Thingy.create(:featured => false)
      
      will_be_featured.featured = true
      will_be_featured.save!
      
      originally_featured.reload
      will_be_featured.reload
      
      featured(Thingy).should have(1).item
      originally_featured.featured?.should be_false
      will_be_featured.featured?.should be_true
    end

    it 'should set another thingy to be featured when removing featured status from the featured thingy' do
      3.times { Thingy.create(:featured => false) }
      originally_featured = Thingy.create(:featured => true)

      originally_featured.featured = false
      originally_featured.save!
      originally_featured.reload
      
      featured(Thingy).should have(1).item
      originally_featured.featured?.should be_false
    end

    it 'should set another thingy to be featured when destroying the featured thingy' do
      3.times { Thingy.create(:featured => false) }
      originally_featured = Thingy.create(:featured => true)

      originally_featured.destroy
      
      featured(Thingy).should have(1).item
    end
  end
  
  describe "with a scope" do
    after(:each) do
      ThingyAggregator.delete_all
      ScopedThingy.delete_all
    end
    
    it 'should constrain featured status to scope' do
      aggregator1 = ThingyAggregator.create
      aggregator2 = ThingyAggregator.create
      
      3.times { aggregator1.scoped_thingies.create(:featured => false) }
      3.times { aggregator2.scoped_thingies.create(:featured => false) }
      f1 = aggregator1.scoped_thingies.create(:featured => true)
      f2 = aggregator2.scoped_thingies.create(:featured => true)

      featured(ScopedThingy).should have(2).items
      
      f1.update_attribute(:featured, false)
      
      featured(ScopedThingy).should have(2).items
      aggregator2.scoped_thingies.find_by_featured(true).should == f2
    end
    
    it 'should not explode when the scope is nil' do
      lambda {
        ScopedThingy.create!(:featured => true)
        featured(ScopedThingy).should have(1).item
      }.should_not raise_error
    end
  end
  
  describe "named scope" do
    it 'should add a default named scope' do
      DefaultNamedScopeThingy.scopes.should have_key(:featured)
    end

    it 'should add a custom named scope' do
      CustomNamedScopeThingy.scopes.should have_key(:special!)
    end
    
    it 'should return the featured thingy from the named scope' do
      3.times { DefaultNamedScopeThingy.create!(:featured => false) }
      t = DefaultNamedScopeThingy.create!(:featured => true)
      DefaultNamedScopeThingy.featured.first.should == t
    end
  end
end
