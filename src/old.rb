require 'set'
require 'pp'
require 'optparse'
require 'fileutils'
require_relative 'scp-article-loader'
require_relative 'roff-builder'
require_relative 'locale'

option = {
  :locale => SITE::EN,
  :manpath => File.expand_path("~/.old/man")
}
OptionParser.new do |opt|
  opt.on('-l', '--locale=locale') do |locale|
    option[:locale] = SITE.create(locale)
  end
  opt.parse! ARGV
end

article = ""
item_no = ARGV[0]
begin
  subject = SCPArticleLoader.new(item_no, option)
  builder = RoffBuilder.new(subject.article)
  builder.title = "SCP-#{item_no}"
  builder.section = 7
  builder.date = Time.now
  builder.source = "SCP Foundation"
  builder.manual = "SCP Database"
  builder.hr_width = `tput cols`.chomp.to_i
  builder.name = subject.title
  roff = builder.build
  article = roff
rescue

  article = <<-"EOS"
.TH "SCP-#{item_no}" 7 "#{Time.now.strftime("%Y-%m-%d")}" "SCP Foundation" "SCP Database"
.ce 1
[ACCESS DENIED]
.brp
EOS
end

path = "#{option[:manpath]}/#{get_locale(option[:locale])}/man7/"
FileUtils.mkdir_p(path) unless FileTest.exist?(path)
filepath = path + "scp-#{item_no}.7"
File.open(filepath, "w") do |file|
  file.puts article
end

puts filepath
