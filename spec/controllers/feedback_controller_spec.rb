require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  let(:feedback) { build :feedback }
  let(:mail) { double 'ActionMailer Mail'}

  let(:params) do
    {
      feedback: {
        ease_of_use:  feedback.ease_of_use,
        completeness: feedback.completeness,
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

      it 'enqueues an EmailFeedbackJob with our feedback' do

        # FeedbackMailer.new_feedback(@feedback).deliver_later
        expect(FeedbackMailer).to receive(:new_feedback).with(instance_of(Feedback)).and_return(mail)
        expect(mail).to receive(:deliver_later)
        post :create, params: params
      end

      it 'renders the confirmation template' do
        expect(post :create, params: params)
          .to render_template(:confirmation)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          feedback: {
            # no :ease_of_use or :completeness
            comment: feedback.comment
          }
        }
      end

      it 'does not make a DB entry' do
        expect { post :create, params: params }
          .not_to change { Feedback.count }
      end

      it 'does not enqueue an EmailFeedbackJob' do
        expect(FeedbackMailer).not_to receive(:new_feedback)
        post :create, params: params
      end

      it 'renders the :new template' do
        expect(post :create, params: params)
          .to render_template(:new)
      end
    end
  end

end
