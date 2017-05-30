class Ld::Controllers

  attr_accessor :headings, :rows

  def initialize project
    @project = project
    root = @project.root
  end

end