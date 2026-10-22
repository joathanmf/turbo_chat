# Strict CSP: only our own scripts/styles, inline ones need the per-request nonce.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.connect_src :self
    policy.font_src    :self
    policy.img_src     :self, :data
    policy.manifest_src :self
    policy.script_src  :self
    policy.style_src   :self
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
