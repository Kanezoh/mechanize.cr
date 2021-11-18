class Mechanize
  # This is a fake node used when sending post request.
  class Node < Hash(String, String)
    def css(str)
      [] of Hash(String, String)
    end

    def inner_text
      ""
    end
  end
end
