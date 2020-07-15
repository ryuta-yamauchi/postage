require "open-uri"
require "nokogiri"
require "kconv"

module Postage
  module KuronekoyamatoMethod

    URL = "http://www.kuronekoyamato.co.jp/ytc/search/estimate/ichiran.html".freeze

    def initialize(from, to, size)
      @from = from
      @to = to
      @size = size
    end

    def price
    end

    # { "北海道" => ["北海道"], "北東北" => ["青森県", "秋田県", "岩手県"] }
    def area_mapping_hash
      hash = {}
      areas = page.search("table.chartA").first.children[1].text.split("\n").reject(&:empty?).compact
      # "地域" "発地" の文字列を取り除く
      areas.slice!(0, 2)
      prefs = page.search("table.chartA").first.children[3].children.map { |element| element if !element.text.gsub(/[[:space:]]/, '').empty? && element.text != "\n" }.compact
      areas.each_with_index { |area, i| hash[area] = prefs[i].children.map {|pref| pref.text }.reject(&:empty?) }
      hash
    end

    def page
      return @page unless @page.nil?
    
      html = URI.open(URL) { |f| f.read }
      @page = Nokogiri::HTML.parse(html.toutf8, nil, "utf-8")
      @page
    end

    def area_from_pref(pref)
      area_mapping_hash.find { |key, value| value.include?(pref) }[0]
    end
  end
end
