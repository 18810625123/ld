class Ld::Views

  attr_accessor :headings, :rows

  def initialize project
    @project = project
    root = @project.root
  end

end