require 'rails_helper'

RSpec.describe Correspondence, type: :model do

  subject { build :correspondence }

  describe 'test object instantiated by FactoryGirl' do
    it { should be_valid }
  end

  describe 'each category' do
    Settings.correspondence_categories.each do |category|
      it 'has a specific email address associated' do
        expect(ENV["#{category.upcase}_EMAIL"]).not_to be nil
      end
    end
  end

  describe 'attributes' do

    it { should validate_presence_of      :name }
    it { should validate_presence_of      :email }
    it { should validate_presence_of      :category }
    it { should validate_presence_of      :topic }
    it { should validate_presence_of      :message }
    it { should validate_confirmation_of  :email}
  
    it do
      should validate_inclusion_of(:topic).
        in_array(Settings.correspondence_topics)
    end

    it do
      should validate_inclusion_of(:category).
        in_array(Settings.correspondence_categories)
    end

    it { should allow_value('foo@bar.com').for :email }
    it { should_not allow_value('foobar.com').for :email  }
  end
end
