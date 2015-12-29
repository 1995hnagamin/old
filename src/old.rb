require 'set'
require 'pp'
require_relative 'loader'

@width = `tput cols`.chomp.to_i

def join_roffs(roffs)
  roffs.join("")
end

def span2roff(e, child)
  child
end

def is_section_title?(string)
  # regard as a section title when:
  # * inner text ends width ':'
  #   like "Description:", "Item #:" ...
  # * inner text contains characteristic words
  title_patterns = [
    /^Item #:$/,
    /^Special Containment Procedures:$/,
    /^Object Class:$/,
    /^Status/,
    /^Description:$/,
    /^[a-zA-Z ]*[Ll]og/,
    /^Addendum/,
    /^Appendix/,
    /^Notes [0-9]+/,
    /^Document.*[0-9]+/
  ]
  title_patterns.any? {|pattern| string =~ pattern }
end

def table2roff(table)
  rows = table.xpath("tr")
  column = rows.first.xpath("td").length
  separater = "^"
  content = rows.map { |tr|
    row = tr.xpath("td").map { |td|
      elem2roff(td, false) + separater
    }.join("")
  }.join("\n")
  <<EOS
.TS
tab(#{separater});
#{"l " * column }.
#{content}
.TE
EOS
end

def elem2roff(e, title = true)
  children = e.children.map { |ch| html2roff(ch, title) }
  case e.name
  when "strong"
    child = children.join("")
    if title and is_section_title?(child)
      "\n.SH \"#{child.gsub(/:[ ]*$/, "") }\"\n"
    else
      "\\fB#{child}\\fR"
    end
  when "br"
    "\n.PP\n"
  when "hr"
    "\n.ce 1\n\\l'#{@width / 4 * 3}'\n.ce 0\n"
  when "blockquote"
    children = e.children.map { |ch| html2roff(ch, false) }
    join_roffs(children)
  when "p"
    "\n.br\n#{join_roffs(children)}\n.br\n"
  when "span"
    child = join_roffs(children)
    span2roff(e, child)
  when "table"
    table2roff(e)
  else
    join_roffs(children)
  end
end

def html2roff(e, title = true)
  if e.text?
    return e.text + (e.text[-1] == '.' ? " ": "")
  elsif e.elem?
    elem2roff(e, title)
  end
end

begin
  item_no = ARGV[0]
  subject = SCPArticleLoader.new(item_no)
  article = subject.article
  paragraphs = article.xpath('p|hr|blockquote|div/blockquote|br|table').map do |node|
    html2roff(node)
  end
  roff = join_roffs(paragraphs)
  name = subject.title

  puts <<-"EOS"
.TH "SCP-#{item_no}" 7 "#{Time.now.strftime("%Y-%m-%d")}" "SCP Foundation" "SCP Database"
.SH NAME
#{name}

#{roff}
EOS
rescue

  puts <<-"EOS"
.TH "SCP-#{item_no}" 7 "#{Time.now.strftime("%Y-%m-%d")}" "SCP Foundation" "SCP Database"
.ce 1
[ACCESS DENIED]
.brp
EOS

end
