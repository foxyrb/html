# frozen_string_literal: true

require "delegate"

module Foxy
  module Html
    class Collection
      attr_reader :objects

      alias to_ary objects
      alias to_a objects

      def initialize(objects)
        @objects = objects
      end

      def ==(other)
        other.respond_to?(:to_a) && objects == other.to_a
      end

      def attr(name)
        objects.each_with_object([]) { |node, acc| acc << node.attr(name) if node }
      end

      def first
        objects.first
      end

      def count
        objects.count
      end

      def search(**kws)
        filters = kws.delete(:filters) || []

        result = flat_map { |node| node.search(**kws) }

        filters.inject(result) { |memo, filter| memo.public_send(filter) }
      end

      def css(query)
        # query.split(/\s+/).inject(self) { |memo, q| memo.search(**parse_css(q)) }
        query.scan(/(?:(?:[^\s\[]+)|(?:\[[^\]]+\]))+/).inject(self) { |memo, q| memo.search(**parse_css(q)) }
      end

      def texts
        objects.map(&:texts)
      end

      def joinedtexts
        objects.each_with_object([]) { |node, acc| acc << node.joinedtexts if node }
      end

      def as_number
        objects.each_with_object([]) { |node, acc| acc << node.as_number if node }
      end

      def map(&block)
        self.class.new(objects.map(&block))
      end

      def filter(&block)
        self.class.new(objects.filter(&block))
      end

      def flat_map(&block)
        self.class.new(objects.flat_map(&block))
      end

      def rebuild
        objects.map(&:to_s).join
      end

      def clean(*args)
        map { |e| e.clean(*args) }
      end

      private

      # assert Foxy::Html.new.parse_css("tag#id") == {tagname: "tag", id: "id"}
      # assert Foxy::Html.new.parse_css("#id") == {id: "id"}
      # assert Foxy::Html.new.parse_css("tag") == {tagname: "tag"}
      # assert Foxy::Html.new.parse_css("tag.cls") == {tagname: "tag", cls: ["cls"]}
      # assert Foxy::Html.new.parse_css(".class") == {cls: ["class"]}
      # assert Foxy::Html.new.parse_css(".class.class") == {cls: ["class", "class"]}
      # assert Foxy::Html.new.parse_css(".cls.class") == {cls: ["cls", "class"]}
      def parse_css(css)
        token = "([^:#\.\s\\[\\]]+)"
        css
          .scan(/#{token}|##{token}|\.#{token}|:#{token}|(?:\[#{token}=#{token}\])/)
          .each_with_object({}) do |(tagname, id, cls, filter, attr_name, attr_value), memo|
          next memo[:tagname] = tagname if tagname
          next memo[:id] = id if id

          if attr_name && attr_value
            next memo.fetch(:attrs) { memo[:attrs] = {} }[attr_name] = attr_value
          end

          memo.fetch(:filters) { memo[:filters] = [] } << filter if filter
          memo.fetch(:cls) { memo[:cls] = [] } << cls if cls
        end
      end
    end
  end
end
