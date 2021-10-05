# frozen_string_literal: true

require 'json'

# Class for working with the radish database.
# Saves the record and returns all records.
class Statistic
  SET_NAME = 'math_test_results'

  # @param [Redis] redis
  def initialize(redis)
    @redis = redis
  end

  # @param [Hash] data_hash
  def save(data_hash)
    data_json = JSON.generate(data_hash)
    @redis.sadd(SET_NAME, data_json)
  end

  # @return [Array]
  def all
    data_json_array = @redis.smembers(SET_NAME)
    data_json_array.map { |member| JSON.parse(member) }
  end
end
