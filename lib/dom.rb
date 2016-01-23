module OLD
  module DOM
    def is_text?(elem)
      elem.text?
    end

    def is_elem?(elem)
      elem.elem?
    end

    def text(elem)
      elem.text
    end

    def children(elem)
      elem.children
    end

    def xpath(elem, query)
      elem.xpath(query)
    end

    def tag_name(elem)
      elem.name
    end
  end
end
