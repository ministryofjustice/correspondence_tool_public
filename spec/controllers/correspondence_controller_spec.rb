require 'rails_helper'

RSpec.describe CorrespondenceController, type: :controller do

  let(:external_user) do
    double 'external_user',
    name: 'Member of public',
    email: 'member_of_public@public.com'
  end

  let(:params) do
    {
      correspondence: {
        name:               external_user.name,
        email:              external_user.email,
        email_confirmation: external_user.email,
        topic:              "prisons_and_probation",
        message:  'Question about prisons and probation from member of public'
      }
    }
  end

  let(:invalid_params) do
    {
      correspondence: {
        # no name
        email:              external_user.email,
        email_confirmation: external_user.email,
        topic:              "prisons_and_probation",
        message:  'Question about prisons and probation from member of public'
      }
    }
  end

  describe 'GET new' do
    before { get :new }

    it { should render_template(:new) }
  end

  describe 'POST create' do
    context 'with valid params' do 

      it 'makes a DB entry' do
        expect { post :create, params: params }
          .to change { Correspondence.count }.by 1
      end

      it 'enqueues an EmailCorrespondenceJob' do
        expect { post :create, params: params }
          .to have_enqueued_job(EmailCorrespondenceJob)
      end

      it 'renders the :confirmation template' do
        expect(post :create, params: params).to render_template(:confirmation)
      end
    end

    context 'with invalid params' do

      it 'does not make a DB entry' do
        expect { post :create, params: invalid_params }
          .to change { Correspondence.count }.by 0
      end

      it 'does not enqueue an EmailCorrespondenceJob' do
        expect { post :create, params: invalid_params }
          .not_to have_enqueued_job(EmailCorrespondenceJob)
      end

      it 'renders the :new template' do
        expect(post :create, params: invalid_params).to render_template(:new)
      end
    end

    context 'when redis is down' do

      before do
        allow(EmailCorrespondenceJob)
          .to receive(:perform_later)
          .and_raise(Redis::CannotConnectError)
        post :create, params: params
      end

        it { should respond_with 500 }
    end
  end

end
