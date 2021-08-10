require "./page"

class MechanizeCr::History < Array(MechanizeCr::Page)
  property max_size : Int32
  def initialize(max_size = 100)
    @max_size = max_size
    super
  end

  def push(page, uri = nil)
    super page
    while self.size > @max_size
      shift
    end
    self
  end

  def pop
    if size == 0
      # TODO: raise error
    end
    page = super
  end
end
