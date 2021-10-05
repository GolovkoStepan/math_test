# frozen_string_literal: true

# Module for creating mathematical examples.
module ExampleGeneration
  MAX_RAND = 100
  OPERATIONS = %w[+ - / *].freeze

  WrongExample = Class.new(StandardError)

  # A class for working with a math example.
  # Retrieves the answer and string representation of the example.
  class MathExample
    MATH_EXAMPLE_REGEXP = %r{^\d+ [+\-*/] \d+$}.freeze
    MAX_FRACTIONAL_PART = 2

    # @param [String] math_example
    def initialize(math_example)
      raise WrongExample unless example_correct?(math_example)

      @math_example = math_example
    end

    # @return [Float]
    def answer
      # rubocop:disable Security/Eval
      @answer ||= eval <<-RUBY, binding, __FILE__, __LINE__ + 1
        (#{math_example}.to_f).round(MAX_FRACTIONAL_PART)
      RUBY
      # rubocop:enable Security/Eval
    end

    def to_s
      @math_example
    end

    private

    attr_reader :math_example

    def example_correct?(math_example)
      MATH_EXAMPLE_REGEXP =~ math_example
    end
  end

  # @return [MathExample]
  def generate
    MathExample.new("#{rand(MAX_RAND)} #{OPERATIONS.sample} #{rand(MAX_RAND)}")
  end
  module_function :generate
end
