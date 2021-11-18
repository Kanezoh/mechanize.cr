# This class represents &lt;input type="checkbox"&gt;
class Mechanize::FormContent::CheckBox < Mechanize::FormContent::RadioButton
  # set checkbox checked
  def check
    @checked = true
  end

  def query_value
    [@name, @value || "on"]
  end
end
