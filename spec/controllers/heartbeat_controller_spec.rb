require 'rails_helper'

RSpec.describe HeartbeatController, type: :controller do


  describe 'ping and heartbeat do not force ssl' do
    before do
      allow(Rails).to receive(:env).and_return(double(development?: false, production?: true))
    end

    after do
      expect(response.status).not_to eq(301)
    end

    it 'ping endpoint' do
      get :ping
    end

    it 'healthcheck endpoint' do
      get :healthcheck
    end
  end

  describe '#ping' do
    context 'when environment variables not set' do
      before do
        Rails.application.config.version_number = "Not Available"
        Rails.application.config.build_date     = "Not Available"
        Rails.application.config.commit_id      = "Not Available"
        Rails.application.config.build_tag      = "Not Available"
        get :ping
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values)
            .to eq( ["Not Available",
                     "Not Available",
                     "Not Available",
                     "Not Available"])
      end
    end

    context 'when environment variables set' do

      before do
        Rails.application.config.version_number = '123'
        Rails.application.config.build_date     = '20150721'
        Rails.application.config.commit_id      = 'afb12cb3'
        Rails.application.config.build_tag      = 'test'

        get :ping
      end

      it 'returns JSON with app information' do
        expect(response.body).to eq({version_number: '123',
                                     build_date:     '20150721',
                                     commit_id:      'afb12cb3',
                                     build_tag:      'test'
                                    }.to_json)
      end
    end
  end

  describe '#healthcheck' do
    before do
      allow(Sidekiq::ProcessSet)
          .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::RetrySet)
          .to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
      allow(Sidekiq::DeadSet)
          .to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
    end

    context 'when a problem exists' do
      before do
        allow(ActiveRecord::Base.connection)
            .to receive(:active?).and_raise(PG::ConnectionBad)
        allow(Sidekiq::ProcessSet)
            .to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))
        allow(Sidekiq::DeadSet)
            .to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))

        connection = double('connection')
        allow(connection).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it 'returns status bad gateway' do
        expect(response.status).to eq(502)
      end

      it 'returns the expected response report' do
        expect(response.body).to eq({checks: { database: false,
                                               redis: false,
                                               sidekiq: false,
                                               sidekiq_queue: false
        }}.to_json)
      end
    end

    context 'when everything is ok' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)

        connection = double('connection', info: {})
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      it 'returns HTTP success' do
        expect(response.status).to eq(200)
      end

      it 'returns the expected response report' do
        expect(response.body).to eq({checks: { database: true,
                                               redis: true,
                                               sidekiq: true,
                                               sidekiq_queue: true
        }}.to_json)
      end
    end
  end
end
