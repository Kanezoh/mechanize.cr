# This class represents <input type="checkbox">
class Mechanize::FormContent::CheckBox < Mechanize::FormContent::RadioButton
  # set checkbox checked
  def check
    @checked = true
  end

  def query_value
    [@name, @value || "on"]
  end
end
