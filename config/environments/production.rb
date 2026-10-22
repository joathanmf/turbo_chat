require "active_support/core_ext/integer/time"
require "active_support/core_ext/numeric/bytes"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { hsts: { subdomains: true, preload: true, expires: 1.year } }

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # ponytail: in-process cache (only used by rate_limit); per-process, resets on deploy.
  config.cache_store = :memory_store, { size: 32.megabytes }

  config.i18n.fallbacks = true

  # config.hosts = [ "chat.example.com" ]
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
