require 'spec_helper'

RSpec.describe ActsAsFeatured do
  def featured(model)
    model.where(featured: true)
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
      expect(featured(Thingy).first).to eq(originally_featured)
      originally_featured.save
      expect(featured(Thingy).first).to eq(originally_featured)
    end

    it 'should remove featured status from the currently featured thingy when setting it on another thingy' do
      originally_featured = Thingy.create(:featured => true)
      will_be_featured = Thingy.create(:featured => false)

      will_be_featured.featured = true
      will_be_featured.save!

      originally_featured.reload
      will_be_featured.reload

      expect(featured(Thingy).count).to eq(1)
      expect(originally_featured).not_to be_featured
      expect(will_be_featured).to be_featured
    end

    it 'should set another thingy to be featured when removing featured status from the featured thingy' do
      3.times { Thingy.create(:featured => false) }
      originally_featured = Thingy.create(:featured => true)

      originally_featured.featured = false
      originally_featured.save!
      originally_featured.reload

      expect(featured(Thingy).count).to eq(1)
      expect(originally_featured).not_to be_featured
    end

    it 'should set another thingy to be featured when destroying the featured thingy' do
      3.times { Thingy.create(:featured => false) }
      originally_featured = Thingy.create(:featured => true)

      originally_featured.destroy

      expect(featured(Thingy).count).to eq(1)
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

      expect(featured(ScopedThingy).count).to eq(2)

      f1.update_attributes(:featured => false)

      expect(featured(ScopedThingy).count).to eq(2)
      expect(aggregator2.scoped_thingies.find_by_featured(true)).to eq(f2)
    end

    it 'should not explode when the scope is nil' do
      expect {
        ScopedThingy.create!(:featured => true)
        expect(featured(ScopedThingy).count).to eq(1)
      }.not_to raise_error
    end
  end

  describe "named scope" do
    it 'should add a default named scope' do
      expect(DefaultNamedScopeThingy).to respond_to(:featured)
    end

    it 'should add a custom named scope' do
      expect(CustomNamedScopeThingy).to respond_to(:special)
    end

    it 'should return the featured thingy from the named scope' do
      3.times { DefaultNamedScopeThingy.create!(:featured => false) }
      t = DefaultNamedScopeThingy.create!(:featured => true)
      expect(DefaultNamedScopeThingy.featured.first).to eq(t)
    end
  end
end
