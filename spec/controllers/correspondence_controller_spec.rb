require "rails_helper"

RSpec.describe CorrespondenceController, type: :controller do
  let(:external_user) do
    double "external_user",
           name: "Member of public",
           email: "member_of_public@public.com"
  end

  let(:correspondence_params) do
    {
      name: external_user.name,
      email: external_user.email,
      email_confirmation: external_user.email,
      topic: "prisons and probations",
      message: "Question about prisons and probation",
    }
  end

  let(:params) do
    {
      correspondence: correspondence_params,
    }
  end

  let(:mail) { double "Action::Mailer Mail" }

  describe "GET topic" do
    it "renders the topic form" do
      expect(get(:topic)).to render_template(:topic)
    end
  end

  describe "GET search" do
    context "with a topic specified" do
      let(:params) { { "correspondence" => { "topic" => "complaints about prisons" }, "commit" => "Send" } }

      before do
        search_client = double GovUkSearchApi::Client
        @result = double "GovUkSearchClient result"
        expect(GovUkSearchApi::Client).to receive(:new).and_return(search_client)
        expect(search_client).to receive(:search).and_return(@result)
      end

      it "renders the search template" do
        expect(get(:search, params:)).to render_template(:search)
      end

      it "instantiates a correspondence object with the search term" do
        get(:search, params:)
        expect(assigns(:correspondence).topic).to eq "complaints about prisons"
      end

      it "calls the search client and stores results" do
        get(:search, params:)
        expect(assigns(:search_result)).to eq @result
      end
    end

    context "with no topic specified" do
      let(:params) { { "correspondence" => { "topic" => "" }, "commit" => "Send" } }

      it "re-renders the topic form" do
        expect(get(:search, params:)).to render_template(:topic)
      end

      it "has a flash error message" do
        get(:search, params:)
        expect(assigns(:correspondence).errors[:topic]).to include(" can't be blank")
      end
    end
  end

  describe "GET authenticate" do
    let!(:correspondence) { create :correspondence }

    context "record not authenticated" do
      it "sets the authenticated_at date" do
        Timecop.freeze(Time.zone.local(2017, 4, 13, 12, 11, 10)) do
          get :authenticate, params: { uuid: correspondence.uuid }
          expect(correspondence.reload.authenticated_at).to eq Time.zone.local(2017, 4, 13, 12, 11, 10)
        end
      end

      it "fires off an email to the team" do
        expect(CorrespondenceMailer).to receive(:new_correspondence).with(correspondence).and_return(mail)
        expect(mail).to receive(:deliver_later)
        get :authenticate, params: { uuid: correspondence.uuid }
      end
    end

    context "uuid not in database" do
      it "responds Not found" do
        get :authenticate, params: { uuid: "ffffffff-eeee-dddd-cccc-bbbbbbbbbbb" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "record already authenticated" do
      let(:authenticated_time) { 20.minutes.ago }

      before { correspondence.authenticated_at = authenticated_time }

      it "does not update the authenticated at date" do
        get :authenticate, params: { uuid: "3cc98e93-d11c-42ad-832d-f40113d3ec27" }
        expect(correspondence.authenticated_at).to eq authenticated_time
      end

      it "does not resend the email" do
        get :authenticate, params: { uuid: "3cc98e93-d11c-42ad-832d-f40113d3ec27" }
        expect(CorrespondenceMailer).not_to receive(:new_correspondence)
      end
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "makes a DB entry" do
        expect { post :create, params: }
          .to change(Correspondence, :count).by 1
      end

      it "enqueues an EmailConfirmationJob" do
        expect(ConfirmationMailer).to receive(:new_confirmation).with(instance_of(Correspondence)).and_return(mail)
        expect(mail).to receive(:deliver_later)
        post :create, params:
      end

      it "redirects to the confirmation action" do
        post(:create, params:)
        correspondence = Correspondence.last
        expect(response).to redirect_to(correspondence_confirmation_path(correspondence.uuid))
      end
    end

    it "defaults the category to general enquiry" do
      post(:create, params:)
      expect(assigns(:correspondence).category).to eq "general_enquiries"
    end

    context "with smoke_test form field set to true" do
      let(:params) do
        {
          correspondence: correspondence_params,
          smoke_test: true,
        }
      end

      it "sets the category to smoke_test" do
        post(:create, params:)
        expect(assigns(:correspondence).category).to eq "smoke_test"
      end
    end

    context "with invalid params" do
      let(:correspondence_params) do
        {
          # no name
          email: external_user.email,
          email_confirmation: external_user.email,
          topic: "prisons and probations",
          message: "Question about prisons and probation",
        }
      end

      it "does not make a DB entry" do
        expect { post :create, params: }
          .not_to change(Correspondence, :count)
      end

      it "does not send an Correspondence mail" do
        expect(CorrespondenceMailer).not_to receive(:new_correspondence)
        post :create, params:
      end

      it "does not enqueue an Confirmation mail" do
        expect(ConfirmationMailer).not_to receive(:new_confirmation)
        post :create, params:
      end

      it "renders the :search template" do
        expect(post(:create, params:)).to render_template(:search)
      end
    end

    context "when redis is down" do
      before do
        allow(ConfirmationMailer)
          .to receive(:new_confirmation)
          .and_raise(Redis::CannotConnectError)
        post :create, params:
      end

      it { is_expected.to respond_with 500 }
    end
  end

  describe "GET confirmation" do
    it "assigns the correspondence item" do
      item = create :correspondence
      get :confirmation, params: { uuid: item.uuid }
      expect(assigns(:correspondence)).to eq item
    end
  end
end
