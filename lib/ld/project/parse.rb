module Ld::Project::Parse

  def parse_routes root
    system "rake routes > #{root.path}/routes.txt"
    rows = root.find('routes.txt').lines.map{|line|
      arr = line.split(' ')
      arr.unshift(nil) if arr.size == 3
      arr
    }
               .delete_if{|arr| arr.size >= 5 or arr.size <= 2  }
               .map{|row|
      controller, action = row[3].split('#')
      type        = row[1]
      help_method = row[0]
      uri         = row[2]
      #
      [controller, action, type, uri, help_method]
    }
    File.delete("#{root.path}/routes.txt") if File.exist? "#{root.path}/routes.txt"
    {
        :headings => ['控制器', 'action', '请求类型','URI','帮助方法'],
        :rows => rows
    }
  end

  def parse_schema root
    lines = root.db.find('schema.rb').lines
    tables = {}
    read_flag = false
    table = ""
    lines.each do |l|
      if l.lstrip.rstrip.split('end').size == 0
        read_flag = false
      end
      if l.match(/create_table /) and l.match(/ do /)
        read_flag = true
        table = l.split('"')[1]
        tables[table] = []
      end
      if read_flag
        tables[table] << l
      end
    end
    rows = tables.map{|k, v|
      v.delete_at(0)
      [k, v.join(':')]
    }
    {
        :headings => ['tables', 'comment'],
        :rows => rows
    }
  end

  def parse_models root
    rows =  []
    @models = root.app.models.search_files(/.rb$/)
    @controllers = root.app.controllers.search_files(/_controller.rb$/)
    @views = root.app.views.search_dirs
    @tables = parse_schema root
    @models.each do |model_file|
      model_name    = model_file.name.split('.')[0]
      next if !@tables[model_name.pluralize]
      model_lines   = model_file.lines
      actions_full_name = model_lines.map{|l| l.split('def ')[1] if l.match(/def /)}.compact
      actions = actions_full_name.map{|action| action.split(' ')[0]}
      model_instance = eval("#{model_name.camelize}.new")
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
          (views.nil? ? '' : views.map{|v| "#{v.name.split('.')[0]}-#{v.path}"}.join(',')), # 视图
          (controller_methods.nil? ? 0 : controller_methods.size),  # action-size
          (controller_methods.nil? ? '' : controller_methods.join(',')) # actions
      ]
    end
    rows = rows.compact.sort{|a,b| b[2] <=> a[2]} # 按 模型文件行数 排序
    {
        :headings => ['模型','类',
                      '模型lines','模型文件',
                      '控制器文件','控制器lines',
                      '模型方法size','模型方法',
                      '字段size','字段',
                      '视图size', '视图',
                      'action-size','actions'],
        :rows => rows
    }
  end
  
end