require 'set'
require 'pp'
require 'optparse'
require_relative 'scp-article-loader'
require_relative 'roff-builder'

option = {
  :locale => "www"
}
OptionParser.new do |opt|
  opt.on('-l', '--locale=locale') { |locale| option[:locale] = locale }
  opt.parse! ARGV
end

article = ""
begin
  item_no = ARGV[0]
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

puts article
