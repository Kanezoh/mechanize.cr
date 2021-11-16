require "./page"

# This class represents the history of http response you sent.  
# If you send a request, mechanize saves the history.
class Mechanize::History
  # max page size history can save. default is 100.  
  # as same as `agent.max_history`.
  property max_size : Int32
  property array : Array(Mechanize::Page)

    delegate :size, :empty?, :last, to: array

    def initialize(max_size = 100, array = Array(Mechanize::Page).new)
      @max_size = max_size
      @array = array
    end

  # add page to history.
  def push(page, uri = nil)
    @array.push(page)
    while size > @max_size
      @array.shift
    end

  # take the last page out from history.
  def pop
    if size == 0
      # TODO: raise error
    end
  end
end
