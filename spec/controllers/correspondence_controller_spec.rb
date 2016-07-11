require 'rails_helper'

RSpec.describe CorrespondenceController, type: :controller do

  let(:external_user) { double 'external_user', name: Faker::Name.name, email: Faker::Internet.email }
  let(:params) do
    {
      correspondence: {
        name: external_user.name,
        email: external_user.email,
        email_confirmation: external_user.email,
        type: "Freedom of Information Request",
        sub_type: "Prisons",
        message: Faker::Lorem.paragraph[1]
      }
    }
  end

  describe 'GET new' do
    before { get :new }

    it 'renders the :new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      before { post :create, params: params }

      it 'renders the confirmation template' do
        expect(response).to render_template(:confirmation)
      end
    end

    context 'with invalid params' do
      before do
        invalid_params = params
        invalid_params[:correspondence].delete(:name)
        post :create, params: invalid_params
      end

      it 'renders the :new template' do
        expect(response).to render_template(:new)
      end
    end
  end

end
