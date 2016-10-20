Rails.application.configure do
  config.version_number  = ENV.fetch('APP_VERSION_NUMBER' , 'Not Available')
  config.build_date      = ENV.fetch('APP_BUILD_DATE' , 'Not Available')
  config.commit_id       = ENV.fetch('APP_COMMIT_ID' , 'Not Available')
  config.build_tag       = ENV.fetch('APP_BUILD_TAG' , 'Not Available')
end