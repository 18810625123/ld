class Ld::Controllers

  attr_accessor :headings, :rows

  def initialize root, models
    @root = root
    @models = models
    parse
  end

  def parse
    @rows = @root.app.controllers.search_files(/_controller.rb$/).map { |c|
      model_name = c.name.split('_controller')[0].singularize
      model_name = @models.models.include?(model_name) ? model_name : nil
      lines = c.lines
      actions = lines.map{|l| l.split('def ')[1] if l.match(/def /)}.compact
      [model_name, c.name,actions.size, lines.size, c.path,actions.join(',')]
    }.sort{|a,b| b[2] <=> a[2]}
    @headings = ['所属模型名称', '控制器名','action个数', '文件行数','path', '所有action']
  end

  def parse_by_model_name model_name
    controller = find_controller model_name.pluralize
    if controller
      controller_lines = controller.lines
      controller_methods = controller_lines.map{|l| l.split('def ')[1].chomp if l.match(/def /)}.compact
    end
    controller
  end

  def find_controller model_name
    @controllers.each do |c|
      if c.name.split('_controller.rb')[0] == model_name
        return c
      end
    end
    nil
  end

end