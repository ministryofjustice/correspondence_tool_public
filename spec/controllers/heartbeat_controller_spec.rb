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
    it "returns a minimal JSON status with no build or infrastructure detail" do
      get :ping

      expect(response.body).to eq({ status: "ok" }.to_json)
    end
  end

  describe "#deploy_info" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DEPLOY_DASHBOARD_SHARED_SECRET", nil).and_return("test-secret")
    end

    context "with a valid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "test-secret" }

      it "returns JSON with app information" do
        get :deploy_info

        deploy_info_response = JSON.parse response.body
        expect(deploy_info_response["build_date"]).to eq Settings.build_date
        expect(deploy_info_response["git_commit"]).to eq Settings.git_commit
        expect(deploy_info_response["build_tag"]).to eq Settings.git_source
      end
    end

    context "with an invalid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "wrong-secret" }

      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without a shared secret header" do
      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "#healthcheck" do
    before do
      allow(Sidekiq::ProcessSet)
          .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
    end

    context "when a problem exists" do
      before do
        allow(ActiveRecord::Base.connection)
            .to receive(:execute).and_raise(PG::ConnectionBad)
        allow(Sidekiq::ProcessSet)
            .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))

        connection = double("connection") # rubocop:disable RSpec/VerifiedDoubles
        allow(connection).to receive(:call).with("INFO").and_raise(RedisClient::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it "returns status bad gateway" do
        expect(response.status).to eq(500)
      end

      it "returns the expected response report with no per-service detail" do
        expect(response.body).to eq({ status: "error" }.to_json)
      end

      it "sends report to Sentry" do
        expect(Sentry).to receive(:capture_message).with(String)
        get :healthcheck
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_return(true)

        connection = double("connection") # rubocop:disable RSpec/VerifiedDoubles
        allow(connection).to receive(:call).with("INFO")
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it "returns HTTP success" do
        expect(response.status).to eq(200)
      end

      it "returns the expected response report with no per-service detail" do
        expect(response.body).to eq({ status: "ok" }.to_json)
      end
    end
  end
end
