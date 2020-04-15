# frozen_string_literal: true

RSpec.describe(Foxy::Html::Object) do
  describe ".new" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.yaml" do
        check_file(path, "#{path}.yaml") { |content| Foxy::Html::Object.new(content) }
      end
    end
  end

  describe "#clean" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.clean.yaml" do
        check_file(path, "#{path}.clean.yaml") { |content| Foxy::Html::Object.new(content).clean }
      end
    end
  end

  describe "#rebuild" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.rebuild.yaml" do
        check_file(path, "#{path}.rebuild.yaml") { |content| Foxy::Html::Object.new(content).rebuild }
      end
    end
  end

  describe "#texts" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.texts.yaml" do
        check_file(path, "#{path}.texts.yaml") { |content| Foxy::Html::Object.new(content).texts }
      end
    end
  end

  describe "#comments" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.comments.yaml" do
        check_file(path, "#{path}.comments.yaml") { |content| Foxy::Html::Object.new(content).comments }
      end
    end
  end

  describe "#joinedtexts" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.joinedtexts.yaml" do
        check_file(path, "#{path}.joinedtexts.yaml") { |content| Foxy::Html::Object.new(content).joinedtexts }
      end
    end
  end

  describe "#tables" do
    Dir["#{FIXTURE_FOLDER}/*.html"].each do |path|
      it "#{path}.tables.yaml" do
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
      expect(html.css("#page-footer").clean.rebuild).to eq "<div class=\"row\">\n      <div class=\"large-4 large-centered columns\">\n        <hr/>\n        <div>Powered by <a href=\"http://elementalselenium.com/\">Elemental Selenium</a></div>\n      </div>\n    </div>"
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
      li3 = html.css("ul li")

      expect(li2).to eq li
      expect(li2).to eq li3
    end

    it "template slot[name=my-text]" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)

      texts = html.css("template slot[name=my-text]").joinedtexts

      expect(texts).to eq ["My default text"]
    end

    it "my-paragraph" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)

      # texts = html.css("my-paragraph=").joinedtexts
      texts = html.css("my-paragraph").joinedtexts

      expect(texts).to eq ["Let's have some different text!", "Let's have some different text! In a list!"]
    end

    it "my-paragraph [slot=my-text]" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)

      # texts = html.css("my-paragraph=").joinedtexts
      texts = html.css("my-paragraph [slot=my-text]").joinedtexts

      expect(texts).to eq ["Let's have some different text!", "Let's have some different text! In a list!"]
    end

    it "my-paragraph ul[slot=my-text]" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)

      texts = html.css("my-paragraph ul[slot=my-text]").joinedtexts

      expect(texts).to eq ["Let's have some different text! In a list!"]
    end

    it "div div div" do
      shadowdom = load_fixture("shadowdom.html")
      html = Foxy::Html::Object.new(shadowdom)

      expect(html.css("div div").count).to eq 3
      expect(html.css("div div").objects.map { |object| object.nodes.first.content }).to eq ["<div id=\"flash-messages\" class=\"large-12 columns\">", "<div id=\"content\" class=\"large-12 columns\">", "<div class=\"large-4 large-centered columns\">"]
      expect(html.css("div div div").count).to eq 1
      expect(html.css("div div div").objects.map { |object| object.nodes.first.content }).to eq ["<div style=\"text-align: center;\">"]
    end
  end

  describe "#as_number" do
    it "numbers.html" do
      numbers = load_fixture("numbers.html")
      html = Foxy::Html::Object.new(numbers)
      number = html.css("ul").css("li").as_number

      expect(number).to eq [1, 20, 3000]
    end
  end
end
