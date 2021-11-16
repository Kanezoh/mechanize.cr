require "./page"

class Mechanize
  class History
    property max_size : Int32
    property array : Array(Mechanize::Page)

    delegate :size, :empty?, :last, to: array

    def initialize(max_size = 100, array = Array(Mechanize::Page).new)
      @max_size = max_size
      @array = array
    end

    def push(page, uri = nil)
      @array.push(page)
      while size > @max_size
        @array.shift
      end
      self
    end

    def pop
      if size == 0
        # TODO: raise error
      end
      page = @array.pop
    end
  end
end
