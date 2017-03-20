require 'rails_helper'

RSpec.describe CorrespondenceController, type: :controller do

  let(:external_user) do
    double 'external_user',
    name: 'Member of public',
    email: 'member_of_public@public.com'
  end

  let(:correspondence_params) do
    {
      name:               external_user.name,
      email:              external_user.email,
      email_confirmation: external_user.email,
      topic:              'prisons and probations',
      message:            'Question about prisons and probation'
    }
  end

  let(:params) do
    {
      correspondence: correspondence_params
    }
  end

  describe 'GET topic' do
    it 'renders the topic form' do
      expect(get :topic).to render_template(:topic)
    end
  end

  describe 'GET search' do
    context 'with a topic specified' do
      let(:params) { {'correspondence'=>{'topic'=>'complaints about prisons'}, 'commit'=>'Send'} }

      before(:each) do
        search_client = double GovUkSearchApi::Client
        @result = double 'GovUkSearchClient result'
        expect(GovUkSearchApi::Client).to receive(:new).and_return(search_client)
        expect(search_client).to receive(:search).and_return(@result)
      end

      it 'renders the search template' do
        expect(get :search, params: params).to render_template(:search)
      end

      it 'instantiates a correspondence object with the search term' do
        get :search, params: params
        expect(assigns(:correspondence).topic).to eq 'complaints about prisons'
      end

      it 'calls the search client and stores results' do
        get :search, params: params
        expect(assigns(:search_result)).to eq @result
      end
    end

    context 'with no topic specified' do
      let(:params) { {'correspondence'=>{'topic'=>''}, 'commit'=>'Send'} }
      it 're-renders the topic form' do
        expect(get :search, params: params).to render_template(:topic)
      end

      it 'has a flash error message' do
        get :search, params: params
        expect(assigns(:correspondence).errors[:topic]).to include(" can't be blank")
      end
    end

  end

  describe 'POST create' do
    context 'with valid params' do
      it 'makes a DB entry' do
        expect { post :create, params: params }
          .to change { Correspondence.count }.by 1
      end

      it 'enqueues an EmailCorrespondenceJob' do
        post :create, params: params
        expect(EmailCorrespondenceJob)
          .to have_been_enqueued.with(Correspondence.last)
      end

      it 'enqueues an EmailConfirmationJob' do
        post :create, params: params
        expect(EmailConfirmationJob)
          .to have_been_enqueued.with(Correspondence.last)
      end

      it 'renders the :confirmation template' do
        expect(post :create, params: params).to render_template(:confirmation)
      end
    end

    it 'defaults the category to general enquiry' do
      post :create, params: params
      expect(assigns(:correspondence).category).to eq 'general_enquiries'
    end

    context 'with smoke_test form field set to true' do
      let(:params) do
        {
          correspondence: correspondence_params,
          smoke_test: true
        }
      end

      it 'sets the category to smoke_test' do
        post :create, params: params
        expect(assigns(:correspondence).category).to eq 'smoke_test'
      end
    end

    context 'with invalid params' do
      let(:correspondence_params) do
        {
          # no name
          email:              external_user.email,
          email_confirmation: external_user.email,
          topic:              'prisons and probations',
          message:            'Question about prisons and probation'
        }
      end

      it 'does not make a DB entry' do
        expect { post :create, params: params }
          .not_to change { Correspondence.count }
      end

      it 'does not enqueue an EmailCorrespondenceJob' do
        expect { post :create, params: params }
          .not_to have_enqueued_job(EmailCorrespondenceJob)
      end

      it 'does not enqueue an EmailConfirmationJob' do
        expect { post :create, params: params }
          .not_to have_enqueued_job(EmailConfirmationJob)
      end

      it 'renders the :search template' do
        expect(post :create, params: params).to render_template(:search)
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
