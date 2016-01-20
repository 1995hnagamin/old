require_relative 'dom'

class RoffBuilder
  include DOM
  attr_accessor :title, :section, :date, :source, :manual,
    :hr_width, :name
  def initialize(elem)
    @elem = elem
  end

  def build()
    notable_tags =["p", "hr", "blockquote", "div/blockquote",
                   "br", "table"]
    query = notable_tags.join('|')
    paragraphs = xpath(@elem, query).map do |node|
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
      /^Item #:$/i,
      /^Special Containment Procedures:$/i,
      /^Object class:$/i,
      /^Status/i,
      /^Description:$/i,
      /^[a-zA-Z ]*Log/i,
      /^Addendum/i,
      /^Appendix/i,
      /^Notes [0-9]+/i,
      /^Document.*[0-9]+/i
    ]
    title_patterns.any? {|pattern| string =~ pattern }
  end

  def table2roff(table)
    rows = xpath("table, tr")
    column = xpath(rows.first, "td").length
    separater = "^"
    content = rows.map { |tr|
      row = xpath(tr, "td").map { |td|
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

  def elem2roff(e, context)
    ch_context = context
    ch_context[:depth] = context[:depth] + 1
    ch_context[:order] = -1
    children = children(e).map do |ch|
      ch_context[:order] += 1
      html2roff(ch, ch_context)
    end

    depth = context[:depth]
    order = context[:order]

    case tag_name(e)
    when "strong"
      child = children.join("")
      if depth <= 2 and is_section_title?(child) then
        "\n.SH \"#{child.gsub(/:[ ]*$/, "") }\"\n"
      elsif depth <= 2 and order == 0 then
        "\n.SS \"#{child.gsub(/:[ ]*$/, "") }\"\n"
      else
        "\\fB#{child}\\fR"
      end
    when "br"
      "\n.PP\n"
    when "hr"
      "\n.ce 1\n\\l'#{@hr_width / 4 * 3}'\n.ce 0\n"
    when "blockquote"
      ".RS\n" + children.join("") + "\n.RE\n"
    when "p"
      "\n.br\n#{children.join("").gsub(/^ /, "")}\n.br\n"
    when "span"
      child = children.join("")
      span2roff(e, child)
    when "table"
      table2roff(e)
    else
      children.join("")
    end
  end

  def html2roff(e, context = {:depth => 0, :order => 0})
    if is_text?(e)
      return text(e) + (text(e)[-1] == '.' ? " ": "")
    else
      elem2roff(e, context)
    end
  end
end
