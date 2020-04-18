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

      def to_h
        to_a.to_h
      end

      def attr(name)
        objects.each_with_object([]) { |object, acc| acc << object.attr(name) if object }
      end

      def first
        objects.first
      end

      def last
        objects.last
      end

      def count
        objects.count
      end

      def search(**kws)
        filters = kws.delete(:filters) || []

        result = flat_map { |object| object.search(**kws) }

        filters.inject(result) { |memo, filter| memo.public_send(filter) }
      end

      def css(query)
        # query.split(/\s+/).inject(self) { |memo, q| memo.search(**parse_css(q)) }
        query.scan(/(?:(?:[^\s\[]+)|(?:\[[^\]]+\]))+/).inject(self) do |memo, q|
          memo.search(only_childs: true, **parse_css(q))
        end
      end

      def texts(*args, **kws)
        objects.map { |object| object.texts(*args, **kws) }
      end

      def joinedtexts
        objects.each_with_object([]) do |object, acc|
          acc << object.joinedtexts if object
        end
      end

      def as_number
        objects.each_with_object([]) { |object, acc| acc << object.as_number if object }
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
        attr_token = "([^\\[\\]=]+)"
        (css
                 .scan(/#{token}|##{token}|\.#{token}|:#{token}|(?:\[#{attr_token}=#{attr_token}\])/)
                 .each_with_object({}) do |(tagname, id, cls, filter, attr_name, attr_value), memo|
           next memo[:tagname] = tagname if tagname
           next memo[:id] = id if id

           if attr_name && attr_value
             if attr_value[0] == "/" && attr_value[-1] == "/"
               attr_value = Regexp.new(attr_value[1...-1])
              end
             next memo.fetch(:attrs) { memo[:attrs] = {} }[attr_name] = attr_value
           end

           memo.fetch(:filters) { memo[:filters] = [] } << filter if filter
           memo.fetch(:cls) { memo[:cls] = [] } << cls if cls
         end)
      end
    end
  end
end
