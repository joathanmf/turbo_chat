source "https://rubygems.org"

# Only the Rails frameworks we use: no Active Record, no database.
gem "railties", "~> 8.1.4"
gem "actionpack", "~> 8.1.4"
gem "actionview", "~> 8.1.4"
gem "actioncable", "~> 8.1.4"

gem "propshaft"
gem "puma", ">= 8.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "rubocop-rails-omakase", require: false
end
