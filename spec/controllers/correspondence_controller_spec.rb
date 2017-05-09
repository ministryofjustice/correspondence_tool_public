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

  describe 'GET authenticate' do

    let!(:correspondence) { create :correspondence }

    context 'record not authenticated' do
      it 'sets the authenticated_at date' do
        Timecop.freeze(Time.new(2017, 4, 13, 12, 11, 10)) do
          get :authenticate, params: {uuid: correspondence.uuid}
          expect(correspondence.reload.authenticated_at).to eq Time.new(2017, 4, 13, 12, 11, 10)
        end
      end

      it 'fires off an email to the team' do
        expect(EmailCorrespondenceJob).to receive(:perform_later).with(correspondence)
        get :authenticate, params: {uuid: correspondence.uuid}
      end
    end

    context 'uuid not in database' do
      it 'responds Not found' do
        get :authenticate, params: {uuid: 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbb'}
        expect(response).to have_http_status(404)
      end
    end
    context 'record already authenticated' do

      let(:authenticated_time) { 20.minutes.ago }
      before(:each) { correspondence.authenticated_at = authenticated_time }

      it 'does not update the authenticated at date'do
        get :authenticate, params: {uuid: '3cc98e93-d11c-42ad-832d-f40113d3ec27'}
        expect(correspondence.authenticated_at).to eq authenticated_time
      end

      it 'does not resend the email' do
        get :authenticate, params: {uuid: '3cc98e93-d11c-42ad-832d-f40113d3ec27'}
        expect(EmailCorrespondenceJob).not_to receive(:perform_later)
      end
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'makes a DB entry' do
        expect { post :create, params: params }
          .to change { Correspondence.count }.by 1
      end

      it 'enqueues an EmailConfirmationJob' do
        post :create, params: params
        expect(EmailConfirmationJob)
          .to have_been_enqueued.with(Correspondence.last)
      end

      it 'redirects to the confirmation action' do
        post :create, params: params
        correspondence = Correspondence.last
        expect(response).to redirect_to(correspondence_confirmation_path(correspondence))
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
        allow(EmailConfirmationJob)
          .to receive(:perform_later)
          .and_raise(Redis::CannotConnectError)
        post :create, params: params
      end

      it { should respond_with 500 }
    end
  end

  describe 'GET confirmation' do
    it 'assigns the correspondence item' do
      item = create :correspondence
      get :confirmation, params: { id: item.id }
      expect(assigns(:correspondence)).to eq item
    end
  end
end
