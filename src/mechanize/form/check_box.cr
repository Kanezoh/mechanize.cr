class MechanizeCr::FormContent::CheckBox < MechanizeCr::FormContent::Field
  property :checked
  property :form

  def initialize(node : Node, value : String = node["value"])
    @checked = !!node["checked"]
    @form    = form
    super(node)
  end

  def check
    #uncheck_peers
    @checked = true
  end

  def uncheck
    @checked = false
  end

  def checked?
    checked
  end

  def click
    checked ? uncheck : check
  end
end
