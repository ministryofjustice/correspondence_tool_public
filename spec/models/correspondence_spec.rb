require 'rails_helper'

Rails.describe Correspondence, type: :model do

  let(:correspondence) { build :correspondence }

  describe 'has a factory' do
    it 'that produces a valid object by default' do
      expect(correspondence).to be_valid
    end
  end

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

      it 'subtype' do
        correspondence.sub_type = nil
        expect(correspondence).not_to be_valid
      end
    end
  end

end
