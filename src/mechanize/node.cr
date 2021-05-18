class Node < Hash(String,String)
  property fake : Bool
  def initialize(fake = false)
    @fake = fake
    super()
  end
  
  def search(str)
    if fake
      [] of Hash(String,String)
    end
  end
end
