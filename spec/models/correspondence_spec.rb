require 'rails_helper'

Rails.describe Correspondence, type: :model do

  let(:correspondence) { described_class.new(name: Faker::Name.name, email: Faker::Internet.email, type: 'Freedom of Information Request', sub_type: 'Prisons', message: Faker::Lorem.paragraph[1]) }

  describe 'attributes' do
    context 'mandatory' do
      it 'name' do
        correspondence.name = nil
        expect(correspondence).not_to be_valid
      end

      it 'email' do
        correspondence.email = nil
        expect(correspondence).not_to be_valid
      end

      it 'type' do
        correspondence.type = nil
        expect(correspondence).not_to be_valid
      end

      it 'message' do
        correspondence.message = nil
        expect(correspondence).not_to be_valid
      end
    end

    context 'optional' do
      it 'sub_type' do
        correspondence.sub_type = nil
        expect(correspondence).to be_valid
      end
    end
  end

end