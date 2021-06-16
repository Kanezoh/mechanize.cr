require "./radio_button"
class MechanizeCr::FormContent::CheckBox < MechanizeCr::FormContent::RadioButton
  def check
    @checked = true
  end
  def query_value
    [@name, @value || "on"]
  end
end
