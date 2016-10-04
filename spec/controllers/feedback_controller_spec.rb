require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  let(:feedback) { build :feedback }

  let(:params) do
    {
      feedback: {
        rating:              feedback.rating,
        comment:             feedback.comment
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

      it 'redirects to the home page' do
        expect(response).to redirect_to(correspondence_path)
      end
      it 'sends #perform_later to the EmailFeedbackJob' do
        expect(EmailFeedbackJob).to receive(:perform_later)
        post :create, params: params        
      end

      it 'and a job is enqueued' do
        expect { post :create, params: params }
          .to have_enqueued_job(EmailFeedbackJob)
      end

      it 'and the submission is logged' do
        log = File.readlines(Settings.feedback_log)
        last_log_entry = JSON.parse(log.last)
        user_input = last_log_entry["feedback"]

        expect(user_input["timestamp"]).to eq @timestamp
        expect(user_input["rating"]).to eq feedback.rating.humanize
        expect(user_input["comment"]).to eq feedback.comment
      end
    end

    context 'with invalid params' do
      before do
        invalid_params = params
        invalid_params[:feedback].delete(:rating)
        post :create, params: invalid_params
      end

      it { should render_template(:new) }

    end
  end

end
