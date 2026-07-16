Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self, "https://www.googletagmanager.com"
    policy.style_src   :self
    policy.frame_src   "https://www.googletagmanager.com"
    policy.connect_src :self
    policy.base_uri    :self
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
