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

  describe 'GET new' do
    before { get :new }

    it { should render_template(:new) }
  end

  describe 'POST create' do
    context 'with valid params' do
      before do
        @timestamp = DateTime.now.to_s
        post :create, params: params
      end

      it { should render_template(:confirmation)}

      it 'sends #perorm_later to the EmailCorrespondenceJob' do
        expect(EmailCorrespondenceJob).to receive(:perform_later)
        post :create, params: params        
      end

      it 'and a job is enqueued' do
        expect { post :create, params: params }
          .to have_enqueued_job(EmailCorrespondenceJob)
      end

      it 'and the submission is logged' do
        log = File.readlines(Settings.correspondence_log)
        last_log_entry = JSON.parse(log.last)
        user_input = last_log_entry["correspondence"]

        expect(user_input["timestamp"]).to eq @timestamp
        expect(user_input["name"]).to eq external_user.name
        expect(user_input["email"]).to eq external_user.email
        expect(user_input["topic"]).to eq 'prisons_and_probation'
        expect(user_input["message"])
          .to eq 'Question about prisons and probation from member of public'
      end
    end

    context 'with invalid params' do
      before do
        invalid_params = params
        invalid_params[:correspondence].delete(:name)
        post :create, params: invalid_params
      end

      it { should render_template(:new) }
    end

    context 'when redis is down' do

      before do
        allow(EmailCorrespondenceJob).to receive(:perform_later).and_raise(Redis::CannotConnectError)
        post :create, params: params
      end

        it { should respond_with 500 }
    end
  end

end
