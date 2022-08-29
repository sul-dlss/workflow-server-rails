# frozen_string_literal: true

# NOTE: We silence Redis deprecations to avoid filling up disks with logging
# related to deprecated Redis usage in the Resque gem:
# https://github.com/resque/resque/issues/1794. If this issue is ever resolved
# in Resque and we upgrade to a version of Resque with the fix in it, we can
# roll this back.
Redis.silence_deprecations = true

# Load Resque configuration and controller
redis = Redis.new(host: Settings.redis.hostname,
                  port: Settings.redis.port,
                  db: Settings.redis.db)

Resque.redis = Redis::Namespace.new(Settings.redis.namespace, redis: redis)
