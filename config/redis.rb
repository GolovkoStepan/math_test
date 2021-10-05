# frozen_string_literal: true

require 'redis'

# Configuration of Redis DB
class RedisConnection
  HOST = 'localhost'
  PORT = '6379'
  DB_N = '1'

  # @return [Redis]
  def self.redis
    @redis ||= Redis.new(host: HOST, port: PORT, db: DB_N)
  end
end
