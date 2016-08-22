require 'rails_helper'

RSpec.describe CorrespondenceController, type: :controller do

  let(:external_user) { double 'external_user', name: Faker::Name.name, email: Faker::Internet.email }
  let(:params) do
    {
      correspondence: {
        name: external_user.name,
        email: external_user.email,
        email_confirmation: external_user.email,
        type: "freedom_of_information_request",
        topic: "prisons",
        message: Faker::Lorem.paragraph(1)
      }
    }
  end

  describe 'GET start' do
    before { get :start }

    it 'renders the :start template' do
      expect(response).to render_template(:start)
    end
  end

  describe 'GET :step_topic' do
    before { get :step_topic }

    it 'renders the :step_topic template' do
      expect(response).to render_template(:step_topic)
    end
  end

    end
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

      it 'sends #perorm_later to the EmailCorrespondenceJob' do
        expect(EmailCorrespondenceJob).to receive(:perform_later)
        post :create, params: params        
      end

      it 'and a job is enqueued' do
        expect { post :create, params: params }.to have_enqueued_job(EmailCorrespondenceJob)
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
