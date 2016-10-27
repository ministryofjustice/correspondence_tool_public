require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  let(:feedback) { build :feedback }

  let(:params) do
    {
      feedback: {
        rating:  feedback.rating,
        comment: feedback.comment
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
          .to change { Feedback.count }.by 1
      end

      it 'enqueues an EmailFeedbackJob' do
        expect { post :create, params: params }
          .to have_enqueued_job(EmailFeedbackJob)
      end

      it 'redirects to the webform' do
        expect(post :create, params: params)
          .to redirect_to(correspondence_path)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          feedback: {
            # no rating
            comment: feedback.comment
          }
        }
      end

      it 'does not make a DB entry' do
        expect { post :create, params: params }
          .not_to change { Feedback.count }
      end

      it 'does not enqueue an EmailFeedbackJob' do
        expect { post :create, params: params }
          .not_to have_enqueued_job(EmailFeedbackJob)
      end

      it 'renders the :new template' do
        expect(post :create, params: params)
          .to render_template(:new)
      end
    end
  end

end
