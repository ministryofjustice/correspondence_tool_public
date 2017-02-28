require_relative '../rails_helper'

describe CtpCustomLogger do

  before(:each) do
    allow(Rails).to receive_message_chain('configuration.logstasher.source').and_return('ctp-test')
  end

  context 'log level methods' do
    it 'writes the expected debug message to rails logger' do
      expect(Rails.logger).to receive(:debug).with({event: 'test', message: 'my message', log_level: 'debug', source: 'ctp-test'}.to_json)
      CtpCustomLogger.debug({event: 'test', message: 'my message'})
    end

    it 'writes the expected info message to rails logger' do
      expect(Rails.logger).to receive(:info).with({event: 'test', message: 'my message', log_level: 'info', source: 'ctp-test'}.to_json)
      CtpCustomLogger.info({event: 'test', message: 'my message'})
    end

    it 'writes the expected warn message to rails logger' do
      expect(Rails.logger).to receive(:warn).with({event: 'test', message: 'my message', log_level: 'warn', source: 'ctp-test'}.to_json)
      CtpCustomLogger.warn({event: 'test', message: 'my message'})
    end

    it 'writes the expected error message to rails logger' do
      expect(Rails.logger).to receive(:error).with({event: 'test', message: 'my message', log_level: 'error', source: 'ctp-test'}.to_json)
      CtpCustomLogger.error({event: 'test', message: 'my message'})
    end

    it 'writes the expected fatal message to rails logger' do
      expect(Rails.logger).to receive(:fatal).with({event: 'test', message: 'my message', log_level: 'fatal', source: 'ctp-test'}.to_json)
      CtpCustomLogger.fatal({event: 'test', message: 'my message'})
    end
  end

  context 'non-log level methods' do
    it 'raises method not knwon' do
      expect {
        CtpCustomLogger.invalid_method 'this param', 'that param'
      }.to raise_error NoMethodError, /undefined method .invalid_method/
    end
  end

end