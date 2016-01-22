require 'nokogiri'
require 'mechanize'
require_relative 'locale'

class SCPArticleLoader
  def initialize(item_no, option)
    @item_no = item_no
    @option = option
    @agent = Mechanize.new
    url = "http://#{get_endpoint(@option[:locale])}/scp-#{@item_no}"
    page = @agent.get(url)
    doc = Nokogiri::HTML(page.content.toutf8)
    @article = doc.xpath('//*[@id="page-content"]').first
    @title = nil
  end

  def title()
    return @title if @title
    series = @item_no.to_i / 1000 + 1
    url = "http://www.scp-wiki.net/scp-series" +
      (series > 1 ? "-#{series}" : "")
    page = @agent.get(url)
    doc = Nokogiri::HTML(page.content.toutf8)
    article = doc.at('//*[@class="content-panel standalone series"]')
    @title = article.text.match("SCP-#{@item_no} - (.*)$").to_s
  end

  def article()
    return @article
  end
end
