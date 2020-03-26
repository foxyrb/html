# frozen_string_literal: true

require "bundler/setup"
require "foxy/html"
require "yaml"

SPEC_DIR = __dir__
FIXTURE_FOLDER = "#{SPEC_DIR}/fixtures"

module CommonRspecHelpers
  def load_fixture(file_name)
    File.read("#{FIXTURE_FOLDER}/#{file_name}")
  end

  def check_file(filename, result_filename, &block)
    check_with_file(call_with_file(filename, block), result_filename)
  end

  def check_with_file(current, result_filename)
    save_cache(result_filename, current) unless File.exist?(result_filename)

    expect(current).to eq load_cache(result_filename)
  end

  def call_with_file(filename, block)
    block.(File.read(filename))
  end

  def load_cache(filename)
    YAML.load_file(filename)
  end

  def save_cache(filename, content)
    File.write(filename, content.to_yaml)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.include CommonRspecHelpers
end
