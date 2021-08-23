require "./page"

class MechanizeCr::History
  property max_size : Int32
  property array : Array(MechanizeCr::Page)

  forward_missing_to @array

  def initialize(max_size = 100)
    @max_size = max_size
    @array = Array(MechanizeCr::Page).new
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
