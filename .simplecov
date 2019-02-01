require "simplecov-json"

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
])

SimpleCov.configure do
  command_name "RSpec"
  refuse_coverage_drop
  minimum_coverage_by_file 80
  maximum_coverage_drop 5
  at_exit do
    SimpleCov.result.format!
  end
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/bin/'
  add_filter '/gemfiles/'
  add_filter '/examples/'
end
