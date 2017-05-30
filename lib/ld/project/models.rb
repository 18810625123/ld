class Ld::Models
  attr_accessor :headings, :rows

  def initialize project, tables
    @project = project
    root = @project.root
    rows =  []
    @models = root.app.models.search_files(/.rb$/)
    @controllers = root.app.controllers.search_files(/_controller.rb$/)
    @views = root.app.views.search_dirs
    @models.each do |model_file|
      model_name    = model_file.name.split('.')[0]
      next if model_name == 'application_record'
      begin
        model_instance = parse_class(model_name).new
      rescue
        next
      end

      model_lines   = model_file.lines
      actions_full_name = model_lines.map{|l| l.split('def ')[1] if l.match(/def /)}.compact
      actions = actions_full_name.map{|action| action.split(' ')[0]}
      fields = model_instance.attributes.keys

      controller = find_controller model_name.pluralize
      if controller
        controller_lines = controller.lines
        controller_methods = controller_lines.map{|l| l.split('def ')[1] if l.match(/def /)}.compact
      end

      view = find_view model_name.pluralize
      if view
        views = view.search_files(/.html/)
      end

      rows << [
          model_name,             # 模型
          model_name.camelize,     # 类
          model_lines.size,       # 模型lines
          model_file.path,        # 模型文件
          (controller.nil? ? '' : controller.path),     # 控制器文件
          (controller.nil? ? 0 : controller_lines.size),# 控制器lines
          actions.size,           # 模型方法size
          actions.join(','),      # 模型方法
          fields.size,          # 字段size
          fields.join(','),   # 字段
          (views.nil? ? 0 : views.size), # 视图size
          (views.nil? ? '' : views.map{|v| "#{v.name.split('.')[0]}=>#{v.path}"}.join(',')), # 视图
          (controller_methods.nil? ? 0 : controller_methods.size),  # action-size
          (controller_methods.nil? ? '' : controller_methods.join(',')) # actions
      ]
    end
    rows = rows.compact.sort{|a,b| b[2] <=> a[2]} # 按 模型文件行数 排序
    @headings = ['模型','类',
                  '模型lines','模型文件',
                  '控制器文件','控制器lines',
                  '模型方法size','模型方法',
                  '字段size','字段',
                  '视图size', '视图',
                  'action-size','actions']
    @rows = rows
  end


  def find_controller model_name
    @controllers.each do |c|
      if c.name.split('_controller.rb')[0] == model_name
        return c
      end
    end
    nil
  end

  def find_view model_name
    @views.each do |v|
      if v.name == model_name
        return v
      end
    end
    nil
  end


end
