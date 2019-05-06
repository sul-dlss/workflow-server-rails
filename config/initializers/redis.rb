# Load Resque configuration and controller
redis = Redis.new(host: Settings.redis.hostname,
                  port: Settings.redis.port,
                  thread_safe: true,
                  db: Settings.redis.db)

Resque.redis = Redis::Namespace.new(Settings.redis.namespace, redis: redis)
