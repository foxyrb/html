# frozen_string_literal: true

RSpec.describe(Foxy::Html::Object) do
  describe ".new" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.yaml") { |content| Foxy::Html::Object.new(content) }
      end
    end
  end

  describe "#clean" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.clean.yaml") { |content| Foxy::Html::Object.new(content).clean }
      end
    end
  end

  describe "#rebuild" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.rebuild.yaml") { |content| Foxy::Html::Object.new(content).rebuild }
      end
    end
  end

  describe "#texts" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.texts.yaml") { |content| Foxy::Html::Object.new(content).texts }
      end
    end
  end

  describe "#comments" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.comments.yaml") { |content| Foxy::Html::Object.new(content).comments }
      end
    end
  end

  describe "#joinedtexts" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.joinedtexts.yaml") { |content| Foxy::Html::Object.new(content).joinedtexts }
      end
    end
  end

  describe "#tables" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it path.to_s do
        check_file(path, "#{path}.tables.yaml") { |content| Foxy::Html::Object.new(content).tables }
      end
    end
  end

  describe "#css" do
    it "#page-footer" do
      challenging_dom = load_fixture("challenging_dom.html")
      html = Foxy::Html::Object.new(challenging_dom)

      expect(html.css("#page-footer").joinedtexts).to eq ["Powered by Elemental Selenium"]
      expect(html.css("#page-footer").rebuild).to eq "<div id='page-footer' class=\"row\">\n      <div class=\"large-4 large-centered columns\">\n        <hr>\n        <div style=\"text-align: center;\">Powered by <a target=\"_blank\" href=\"http://elementalselenium.com/\">Elemental Selenium</a></div>\n      </div>\n    </div>"
      expect(html.css("#page-footer").clean.rebuild).to eq "<div>\n      <div>\n        <hr/>\n        <div>Powered by <a href=\"http://elementalselenium.com/\">Elemental Selenium</a></div>\n      </div>\n    </div>"
    end

    it "li" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)
      li = html.css("li")

      expect(li.joinedtexts).to eq ["Let's have some different text!", "In a list!"]
      expect(li.rebuild).to eq "<li>Let's have some different text!</li><li>In a list!</li>"
      expect(li.map(&:rebuild).to_a).to eq ["<li>Let's have some different text!</li>", "<li>In a list!</li>"]
      expect(li.clean.rebuild).to eq "<li>Let's have some different text!</li><li>In a list!</li>"
      expect(li.clean.map(&:rebuild).to_a).to eq ["<li>Let's have some different text!</li>", "<li>In a list!</li>"]
    end

    it "ul li" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)
      li = html.css("li")
      li2 = html.css("ul").css("li")

      expect(li2).to eq li
    end
  end
end
