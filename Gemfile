source "https://rubygems.org"

gem "rails", "8.1.2"

gem "bootsnap", require: false
gem "pg", "~> 1.6"
gem "publishing_platform_app_config"
gem "publishing_platform_sso"
gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

group :development, :test do
  gem "climate_control"
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem "factory_bot_rails"
  gem "publishing_platform_rubocop"
  gem "publishing_platform_test"
  gem "rspec-rails"
  gem "webmock"
end

group :development do
  gem "web-console"
end

group :test do
  gem "simplecov"
end
