require_relative "../rails_helper"

describe CtpCustomLogger do
  before do
    allow(Rails).to receive_message_chain("configuration.logstasher.source").and_return("ctp-test") # rubocop:disable RSpec/MessageChain
  end

  context "with log level methods" do
    it "writes the expected debug message to rails logger" do
      expect(Rails.logger).to receive(:debug).with({ event: "test", message: "my message", log_level: "debug", source: "ctp-test" }.to_json)
      described_class.debug({ event: "test", message: "my message" })
    end

    it "writes the expected info message to rails logger" do
      expect(Rails.logger).to receive(:info).with({ event: "test", message: "my message", log_level: "info", source: "ctp-test" }.to_json)
      described_class.info({ event: "test", message: "my message" })
    end

    it "writes the expected warn message to rails logger" do
      expect(Rails.logger).to receive(:warn).with({ event: "test", message: "my message", log_level: "warn", source: "ctp-test" }.to_json)
      described_class.warn({ event: "test", message: "my message" })
    end

    it "writes the expected error message to rails logger" do
      expect(Rails.logger).to receive(:error).with({ event: "test", message: "my message", log_level: "error", source: "ctp-test" }.to_json)
      described_class.error({ event: "test", message: "my message" })
    end

    it "writes the expected fatal message to rails logger" do
      expect(Rails.logger).to receive(:fatal).with({ event: "test", message: "my message", log_level: "fatal", source: "ctp-test" }.to_json)
      described_class.fatal({ event: "test", message: "my message" })
    end
  end

  context "with non-log level methods" do
    it "raises method not knwon" do
      expect {
        described_class.invalid_method "this param", "that param"
      }.to raise_error NoMethodError, /undefined method .invalid_method/
    end
  end
end
