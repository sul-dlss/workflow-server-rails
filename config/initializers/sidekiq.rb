# frozen_string_literal: true

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis_url }
end
Sidekiq::Client.reliable_push! unless Rails.env.test?
