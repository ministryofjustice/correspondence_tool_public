require "rails_helper"

RSpec.describe HeartbeatController, type: :controller do
  describe "ping and heartbeat do not force ssl" do
    before do
      allow(Rails).to receive(:env).and_return(double(development?: false, production?: true))
    end

    it "ping endpoint" do
      get :ping
      expect(response.status).not_to eq(301)
    end

    it "healthcheck endpoint" do
      get :healthcheck
      expect(response.status).not_to eq(301)
    end
  end

  describe "#ping" do
    it "returns JSON with app information" do
      get :ping

      ping_response = JSON.parse response.body
      # Settings can be nil, and since we don't test Settings anywhere else we do it here.
      expect(ping_response["build_date"]).not_to be_nil
      expect(ping_response["build_date"]).to eq Settings.build_date
      expect(ping_response["git_commit"]).not_to be_nil
      expect(ping_response["git_commit"]).to eq Settings.git_commit
      expect(ping_response["git_source"]).not_to be_nil
      expect(ping_response["git_source"]).to eq Settings.git_source
    end
  end

  describe "#healthcheck" do
    before do
      allow(Sidekiq::ProcessSet)
          .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::RetrySet)
          .to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
      allow(Sidekiq::DeadSet)
          .to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
    end

    context "when a problem exists" do
      before do
        allow(ActiveRecord::Base.connection)
            .to receive(:active?).and_raise(PG::ConnectionBad)
        allow(Sidekiq::ProcessSet)
            .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))
        allow(Sidekiq::DeadSet)
            .to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))

        connection = double("connection")
        allow(connection).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it "returns status bad gateway" do
        expect(response.status).to eq(502)
      end

      it "returns the expected response report" do
        expect(response.body).to eq({ checks: { database: false,
                                                redis: false,
                                                sidekiq: false } }.to_json)
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)

        connection = double("connection", info: {})
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it "returns HTTP success" do
        expect(response.status).to eq(200)
      end

      it "returns the expected response report" do
        expect(response.body).to eq({ checks: { database: true,
                                                redis: true,
                                                sidekiq: true } }.to_json)
      end
    end
  end
end
