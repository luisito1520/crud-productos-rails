# Cobertura de código (la lee SonarQube desde coverage/.resultset.json).
require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Las pruebas escriben en un archivo JSON, así que se ejecutan en serie.
    parallelize(workers: 1)
  end
end
