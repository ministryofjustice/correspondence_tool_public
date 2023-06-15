class CtpCustomLogger
  def self.method_missing(method, *args)
    if %i[debug info warn error fatal].include?(method)
      log(method, args.first)
    else
      super
    end
  end

  def self.log(log_level, options)
    new_options = options.merge(log_level:, source: Rails.configuration.logstasher.source)
    Rails.logger.__send__(log_level, new_options.to_json)
  end

  private_class_method :log
end
