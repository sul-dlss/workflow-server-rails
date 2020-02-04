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
    # raise
    Honeybadger.notify('[WARN] Deprecated call to ObjectVersionService.  ' \
      'This happens when a version was not passed to the workflow service.  ' \
      'We would like to eliminate any call that requires a version and does not provide one.')
    client.object(druid).version.current
  rescue Dor::Services::Client::NotFoundResponse # A 404 error
    1
  end

  private

  def client
    @client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                token: Settings.dor_services.token)
  end
end
