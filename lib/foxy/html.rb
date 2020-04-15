# frozen_string_literal: true

require "foxy/html/version"

module Foxy
  module Html
    class Error < StandardError; end

    RE_HTML = %r{
    (</[a-zA-Z\-]+[^>]*>)               #closetag
    |(<[a-zA-Z\-]+(?:[^/>]|/[^>])*/>)   #singletag
    |(<[a-zA-Z\-]+[^>]*>)               #tag
    |([^<]+)                            #notag
    |(<!--.*?-->)                       #|(<![^>]*>) #comment
    |(.)                                #other}imx.freeze

    RE_TAG = /<([a-zA-Z]+[a-zA-Z0-9\-]*)/m.freeze
    RE_TAG_ID = /id=(("[^"]*")|('[^']*')|[^\s>]+)/m.freeze
    RE_TAG_CLS = /class=(("[^"]*")|('[^']*')|[^\s>]+)/m.freeze
    RE_CLOSETAG = %r{</([a-zA-Z]+[a-zA-Z0-9\-]*)}m.freeze

    SINGLES = %w[meta img link input area base col br hr].freeze
    ALLOW = %w[alt src href title class].freeze
    INLINE_TAGS = %w[a abbr acronym b br code em font i
                     img ins kbd map samp small span strong
                     sub sup textarea].freeze

    BLOCK_TAGS = %w[p h1 h2 h3 h4 h5 h6 ol ul pre address blockquote
                    dl div fieldset form hr noscript table br].freeze

    # source_encoding: "ASCII-8BIT", encode: "UTF-8"
    def self.new(html, source_encoding: nil, encode: nil)
      html = html.body if html.respond_to?(:body)
      html = html.read if html.respond_to?(:read)
      html = html.force_encoding(source_encoding) if source_encoding
      html = html.encode(encode) if encode
      Foxy::Html::Object.new(html)
    end
  end
end

Dir["#{__dir__}/html/**/*.rb"]
  .sort
  .each { |file| require file }
