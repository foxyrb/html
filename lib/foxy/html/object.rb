# frozen_string_literal: true

require "htmlentities"

module Foxy
  module Html
    class Object
      DECODER = HTMLEntities.new

      attr_reader :nodes

      def initialize(html)
        @nodes =
          if html.nil?
            []
          elsif html.respond_to?(:nodes)
            html.nodes
          elsif html.respond_to?(:to_str)
            html.to_str.scan(RE_HTML).map { |args| Node.build(*args) }
          elsif html.respond_to?(:read)
            html.read.scan(RE_HTML).map { |args| Node.build(*args) }
          else
            html
          end
      end

      def clean(**kws)
        Foxy::Html::Object.new(nodes.map { |node| node.clean(**kws) })
      end

      def ==(other)
        other.is_a?(self.class) && nodes == other.nodes
      end

      def isearch(tagname: nil, id: nil, cls: nil, fun: nil, css: nil)
        cls = Array(cls)
        tagname &&= tagname.downcase
        y = 0
        buff = []

        close_tagname = nil
        nodes.each do |node| # [1:-1]:
          # El orden de los if es importante para que devuelva el
          # primer y el ultimo nodo
          if y.zero? && node.tag? && (!tagname || node.tagname! == tagname) &&
             (!id || node.id! == id) && (cls - node.cls!).empty? &&
             (!fun || fun.(node))
            # Guardamos porque pudiera ser que el parametro
            # tagname fuera nil
            close_tagname = node.tagname!
            y += 1

          elsif y && node.tag? && node.tagname! == close_tagname
            y += 1

          end

          buff << node if y > 0

          y -= 1 if y > 0 && node.closetag? && node.tagname! == close_tagname

          next unless buff && y.zero?

          yield Html.new(buff)
          buff = []
          close_tagname = nil
        end
      end

      def search(**kws)
        return Collection.new([self]).search(kws) if kws[:css]

        list = []
        isearch(**kws) { |val| list << val unless val.empty? }
        Collection.new(list)
      end

      def css(query)
        Collection.new([self]).css(query)
      end

      def find(**kws)
        isearch(**kws) { |val| return val unless val.empty? }
        nil
      end

      def rebuild
        nodes.map(&:content).join
      end

      def texts
        nodes.each_with_object([]) do |node, acc|
          if node.type == :notag
            acc << DECODER.decode(node.content)
          elsif BLOCK_TAGS.include?(node.tagname!)
            acc << "\n"
          end
        end
      end

      def comments
        nodes.each_with_object([]) do |node, acc|
          acc << node.content.sub(/^<!--/, "").sub(/-->$/, "") if node.type == :comment
        end
      end

      def joinedtexts
        texts.join.gsub(/[ \r\n\s]+/, " ").strip
      end

      def as_number
        joinedtexts.gsub(",", "").to_i
      end

      def attr(name)
        nodes.first.attr(name)
      end

      def id
        nodes.first.id
      end

      def cls!
        nodes.first.cls!
      end

      def to_s
        rebuild
      end

      def tables
        search(tagname: "table").map do |table|
          table.search(tagname: "tr").map do |tr|
            tr.search(tagname: "td").map(&:joinedtexts)
          end
        end
      end

      def empty?
        nodes.empty?
      end

      %i[src href title].each do |m|
        define_method(m) { attr(m) }
      end
    end
  end
end
