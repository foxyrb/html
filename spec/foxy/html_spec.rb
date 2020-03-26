# frozen_string_literal: true

RSpec.describe(Foxy::Html) do
  it "has a version number" do
    expect(Foxy::Html::VERSION).not_to be nil
  end

  describe ".new" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.yaml") { |content| Foxy::Html.new(content) }
      end
    end
  end
end
