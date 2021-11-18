# This class represents &lt;input type="radio"&gt;
class Mechanize::FormContent::RadioButton < Mechanize::FormContent::Field
  property :checked, :form

  def initialize(node : Node | Lexbor::Node, form : Form)
    @checked = !!node.fetch("checked", nil)
    @form = form
    super(node)
  end

  # set radiobutton checked
  def check
    uncheck_peers
    @checked = true
  end

  # set radiobutton checked
  def uncheck
    @checked = false
  end

  # change radiobutton state checked or unchecked
  def click
    checked ? uncheck : check
  end

  # returns radiobutton checked or not
  def checked?
    checked
  end

  # def hash # :nodoc:
  #  @form.hash ^ @name.hash ^ @value.hash
  # end
  #
  # def label
  #  (id = self['id']) && @form.page.labels_hash[id] || nil
  # end
  #
  # def text
  #  label.text rescue nil
  # end
  #
  # def [](key)
  #  @node[key]
  # end

  # alias checked? checked

  # def == other # :nodoc:
  #  self.class === other and
  #    other.form  == @form and
  #    other.name  == @name and
  #    other.value == @value
  # end
  #
  # alias eql? == # :nodoc:

  private def uncheck_peers
    form.radiobuttons_with(name).try &.each do |b|
      next if b.value == value
      b.uncheck
    end
  end
end
