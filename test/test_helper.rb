# Cobertura de código (la lee SonarQube desde coverage/coverage.json).
require "simplecov"
require "simplecov_json_formatter"
SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter]
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Las pruebas escriben en un archivo JSON, así que se ejecutan en serie.
    parallelize(workers: 1)
  end
end
