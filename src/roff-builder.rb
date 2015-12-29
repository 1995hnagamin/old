class RoffBuilder
  attr_accessor :title, :section, :date, :source, :manual,
    :hr_width, :name
  def initialize(elem)
    @elem = elem
  end

  def build()
    notable_tags =["p", "hr", "blockquote", "div/blockquote",
                   "br", "table"]
    query = notable_tags.join('|')
    paragraphs = @elem.xpath(query).map do |node|
      html2roff(node)
    end
    body = paragraphs.join("")
    <<-"EOS"
.TH "#{@title}" #{@section} "#{@date.strftime("%Y-%m-%d")}" "#{@source}" "#{@manual}"
.SH NAME
#{@name}

#{body}
EOS
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
      "\n.ce 1\n\\l'#{@hr_width / 4 * 3}'\n.ce 0\n"
    when "blockquote"
      children = e.children.map { |ch| html2roff(ch, false) }
      children.join("")
    when "p"
      "\n.br\n#{children.join("")}\n.br\n"
    when "span"
      child = children.join("")
      span2roff(e, child)
    when "table"
      table2roff(e)
    else
      children.join("")
    end
  end

  def html2roff(e, title = true)
    if e.text?
      return e.text + (e.text[-1] == '.' ? " ": "")
    elsif e.elem?
      elem2roff(e, title)
    end
  end
end
