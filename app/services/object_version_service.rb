# frozen_string_literal: true

# Handles retrieving versions for objects from dor-services-app
class ObjectVersionService
  include Singleton

  # @param [String] druid the object identifier to get the version for
  # @return [Integer] the current version of the object from dor-services-app
  # @raises [Faraday::TimeoutError, Dor::Services::Client::NotFoundResponse]
  def self.current_version(druid)
    instance.current_version(druid)
  end

  def current_version(druid)
    client.object(druid).version.current
  rescue Dor::Services::Client::NotFoundResponse # A 404 error
    1
  end

  private

  def client
    @client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                token: Settings.dor_services.token,
                                                token_header: Settings.dor_services.token_header)
  end
end
