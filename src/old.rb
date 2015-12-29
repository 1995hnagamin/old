require 'set'
require 'pp'
require_relative 'scp-article-loader'
require_relative 'roff-builder'

begin
  item_no = ARGV[0]
  subject = SCPArticleLoader.new(item_no)
  builder = RoffBuilder.new(subject.article)
  builder.title = "SCP-#{item_no}"
  builder.section = 7
  builder.date = Time.now
  builder.source = "SCP Foundation"
  builder.manual = "SCP Database"
  builder.hr_width = `tput cols`.chomp.to_i
  builder.name = subject.title
  roff = builder.build
  puts roff
rescue

  puts <<-"EOS"
.TH "SCP-#{item_no}" 7 "#{Time.now.strftime("%Y-%m-%d")}" "SCP Foundation" "SCP Database"
.ce 1
[ACCESS DENIED]
.brp
EOS

end
