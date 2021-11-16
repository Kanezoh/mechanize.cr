class Mechanize::FormContent::CheckBox < Mechanize::FormContent::RadioButton
  def check
    @checked = true
  end

  def query_value
    [@name, @value || "on"]
  end
end
