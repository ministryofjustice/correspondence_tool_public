# == Schema Information
#
# Table name: correspondence
#
#  id               :integer          not null, primary key
#  content          :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :string
#  authenticated_at :datetime
#

require "rails_helper"

RSpec.describe Correspondence, type: :model do
  subject(:correspondence) { build :correspondence }

  let(:create_params) do
    {
      name: "Same Mame",
      email: "same.mame@localhost",
      category: "general_enquiries",
      topic: "some name game",
      message: "This is some name game test.",
    }
  end

  it { is_expected.to be_valid }

  describe "each category" do
    Settings.correspondence_categories.each do |category|
      it "has a specific email address associated" do
        expect(Settings["#{category}_email"]).not_to be nil
      end
    end
  end

  describe "uuid" do
    it { is_expected.to have_readonly_attribute :uuid }

    it "sets a uuid" do
      allow(SecureRandom)
        .to receive(:uuid).and_return("ffffffff-eeee-dddd-cccc-bbbbbbbbbbb")
      correspondence = described_class.create! create_params
      expect(correspondence.uuid).to eq "ffffffff-eeee-dddd-cccc-bbbbbbbbbbb"
    end

    it "does not allow a caller to set uuid on creation" do
      allow(SecureRandom)
        .to receive(:uuid).and_return("ffffffff-eeee-dddd-cccc-bbbbbbbbbbb")
      correspondence = described_class.create!(
        create_params.merge(uuid: "bbbbbbbbbbb-cccc-dddd-eeee-ffffffff"),
      )
      expect(correspondence.uuid).to eq "ffffffff-eeee-dddd-cccc-bbbbbbbbbbb"
    end
  end

  describe "confirmation_code" do
    it "uses the UUID for the confirmation code" do
      correspondence = described_class.create! create_params
      allow(correspondence).to receive(:uuid)
                                 .and_return("88888888-dead-beef-4444-cccccccccccc")
      expect(correspondence.confirmation_code).to eq "dead-beef"
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name).with_message("Full name can't be blank") }
    it { is_expected.to validate_presence_of(:email).with_message("Email can't be blank") }
    it { is_expected.to validate_presence_of :category }
    it { is_expected.to validate_presence_of(:topic).with_message("can't be blank") }
    it { is_expected.to validate_presence_of(:message).with_message("Your message can't be blank") }

    it do
      expect(correspondence).to validate_inclusion_of(:category)
        .in_array(Settings.correspondence_categories)
    end

    it { is_expected.to allow_value("foo@bar.com").for :email }
    it { is_expected.not_to allow_value("foobar.com").for :email  }
    it { is_expected.to validate_length_of(:topic).is_at_most(60) }
    it { is_expected.to validate_length_of(:message).is_at_most(5000).with_message("Message is too long (maximum is 5000 characters)") }

    it { is_expected.to validate_inclusion_of(:contact_requested).in_array(%w[yes no]) }
  end

  describe "#topic_present?" do
    context "when topic present" do
      let(:correspondence) { build :correspondence, topic: "My topic" }

      it "returns true" do
        expect(correspondence.topic_present?).to be true
      end

      it "has no error messages" do
        correspondence.topic_present?
        expect(correspondence.errors).to be_empty
      end
    end

    context "when topic absent" do
      let(:correspondence) { build :correspondence, topic: "" }

      it "returns false" do
        expect(correspondence.topic_present?).to be false
      end

      it "has an error messages" do
        correspondence.topic_present?
        expect(correspondence.errors[:topic]).to eq ["What are you contacting the Ministry of Justice about? can't be blank"]
      end
    end
  end

  describe "#authenticated?" do
    context "when unauthenticated" do
      it "returns false" do
        correspondence = build :correspondence
        expect(correspondence.authenticated?).to be false
      end
    end

    context "when authenticated" do
      it "returns true" do
        correspondence = build :correspondence, :authenticated
        expect(correspondence.authenticated?).to be true
      end
    end
  end

  describe "autenticate!" do
    let(:frozen_time) { Time.zone.local(2017, 4, 13, 22, 33, 44) }

    context "when unauthenticated" do
      it "updates authenticated_at with current time" do
        Timecop.freeze frozen_time do
          correspondence = build :correspondence
          correspondence.authenticate!
          expect(correspondence.authenticated_at).to eq frozen_time
        end
      end
    end

    context "when authenticated" do
      it "does not update the authenticated at time" do
        correspondence = build :correspondence, authenticated_at: frozen_time
        correspondence.authenticate!
        expect(correspondence.authenticated_at).to eq frozen_time
      end
    end
  end

  describe ".message search" do
    let!(:c1) { create :correspondence, message: "aa1" }
    let!(:c2) { create :correspondence, message: "abb1" }
    let!(:c3) { create :correspondence, message: "aa1" }

    describe ".all_by_message" do
      it "returns a collection of the correspondence items with the specified message" do
        expect(described_class.all_by_message("aa1")).to match_array [c1, c3]
        expect(described_class.all_by_message("abb1")).to match_array [c2]
      end

      it "returns an empty collection if there are no records with the specified message" do
        expect(described_class.all_by_message("zz1")).to be_empty
      end
    end

    describe ".first_by_message" do
      it "returns just one correspondence item" do
        expect(described_class.first_by_message("aa1")).to be_instance_of(described_class)
      end

      it "returns one of the items with the specified message" do
        expect(described_class.first_by_message("aa1").message).to eq "aa1"
      end

      it "returns nil if there is no record with the specified message" do
        expect(described_class.first_by_message("xx3")).to be_nil
      end
    end
  end
end
