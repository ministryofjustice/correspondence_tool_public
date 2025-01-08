require "rails_helper"

describe CorrespondenceCreator do
  describe ".new" do
    let(:mail) { instance_double ActionMailer::MessageDelivery }

    context "when no radio button selected" do
      let(:params) { { "contact_requested" => "no" } }

      it "returns :no_op" do
        creator = described_class.new(params)
        expect(creator.result).to eq :no_op
      end

      it "does not create a correspondence item" do
        expect {
          described_class.new(params)
        }.not_to change(Correspondence, :count)
      end
    end

    context "when valid correspondence object created" do
      let(:params) do
        {
          "name" => "Joe",
          "email" => "aa@aa.com",
          "topic" => "my topic",
          "message" => "My message",
          "category" => "general_enquiries",
        }
      end

      it "returns :success" do
        creator = described_class.new(params)
        expect(creator.result).to eq :success
      end

      it "sends confirmation email" do
        allow(ConfirmationMailer).to receive(:new_confirmation).with(instance_of(Correspondence)).and_return(mail)
        expect(mail).to receive(:deliver_later)
        described_class.new(params)
      end

      it "saves a new correspondence object" do
        expect {
          described_class.new(params)
        }.to change(Correspondence, :count).by(1)
      end
    end

    context "with invalid params" do
      let(:params) do
        { "name" => "Joe" }
      end

      it "returns :validation_error" do
        creator = described_class.new(params)
        expect(creator.result).to eq :validation_error
      end

      it "does not save a correspondence obejct" do
        expect {
          described_class.new(params)
        }.not_to change(Correspondence, :count)
      end
    end
  end
end
