# frozen_string_literal: true

require 'tty-prompt'
require_relative 'example_generation'
require_relative 'statistic'

# The class contains the logic of the test
class MathTestRunner
  ACCURACY = 0.15

  def initialize(redis)
    @prompt = TTY::Prompt.new
    @correct_count = 0
    @solve_time = 0
    @stat = Statistic.new(redis)
  end

  def start
    request_info
    run_test
    test_report
    save_statistic
  end

  private

  attr_accessor :prompt, :correct_count, :examples_count, :solve_time, :username, :age

  def request_info
    puts 'Решение математических задач'
    @username       = prompt.ask('Введите ваше имя:')
    @age            = prompt.ask('Введите ваш возраст:')
    @examples_count = prompt.ask('Сколько примеров вы хотите решить (10-100)?') do |q|
      q.in '10-100'
      # rubocop:disable Style/FormatStringToken
      q.messages[:range?] = '%{value} находится вне диапазона %{in}'
      # rubocop:enable Style/FormatStringToken
    end.to_i
  end

  def run_test
    examples_count.times do |i|
      math_example = ExampleGeneration.generate
      time, user_answer = with_time_calc { prompt.ask("#{i + 1}) #{math_example} = ?") }
      self.solve_time += time
      self.correct_count += 1 if (user_answer.to_f - math_example.answer).abs < ACCURACY
    end
  end

  def test_report
    puts 'Результат:'
    puts "Количество правильно решённых примеров: #{correct_count}"
    puts "Общее количество примеров: #{examples_count}"
    puts "Общее время решения: #{(solve_time).round(2)}"
    puts "Среднее время решения: #{(solve_time / examples_count.to_f).round(2)}"
  end

  def save_statistic
    data_hash = {
      name: username,
      age: age,
      correct_count: correct_count,
      total_count: examples_count,
      solve_time: solve_time.round(2),
      solve_time_avg: (solve_time / examples_count.to_f).round(2)
    }

    @stat.save(data_hash)
  end

  def with_time_calc
    start  = Time.now
    answer = yield
    [Time.now - start, answer]
  end
end
