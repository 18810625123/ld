class Ld::Project

attr_accessor :app, :name, :models, :views_dir, :views, :controllers, :routes

  def initialize
    @@root = Ld::File.new Rails.root.to_s
    system "rake routes > #{@@root.config.path}/routes.txt"
    Ld::Excel.create "#{@@root.config.path}/project.xls" do |excel|
      excel.write_sheet 'routes' do |sheet|
        sheet.set_format({color: :black, font_size: 14, font: '微软雅黑'})
        sheet.set_headings ['控制器', 'action', '请求类型','URI','帮助方法']
        sheet.set_point 'a1'
        sheet.set_rows @@root.config.find('routes.txt').lines
                           .map{|line|
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
                         [controller, action, type, uri, help_method]
                       }
      end
      excel.write_sheet 'tables' do |sheet|
        sheet.set_format({color: :black, font_size: 14, font: '微软雅黑'})
        sheet.set_headings ['tables', 'commit']
        sheet.set_point 'a1'
        lines = @@root.db.find('schema.rb').lines
        @tables = {}
        read_flag = false
        table = ""
        lines.each do |l|
          if l.lstrip.rstrip.split('end').size == 0
            read_flag = false
          end
          if l.match(/create_table /) and l.match(/ do /)
            read_flag = true
            table = l.split('"')[1]
            @tables[table] = []
          end
          if read_flag
            @tables[table] << l
          end
        end
        @tables.each do |k, v|
          v.delete_at(0)
          sheet.set_row [k, v.join(':')]
        end
      end

      excel.write_sheet 'models' do |sheet|
        sheet.set_format({color: :black, font_size: 14, font: '微软雅黑'})
        sheet.set_point 'a1'

        @models = @@root.app.models.search_files(/.rb$/)
        @controllers = @@root.app.controllers.search_files(/_controller.rb$/)
        @views = @@root.app.views.search_dirs

        rows =  []
        @models.each do |model_file|
          model_name    = model_file.name.split('.')[0]
          next if @tables[model_name.pluralize].nil?

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
        rows = rows.compact.sort{|a,b| b[2] <=> a[2]}  # 按 模型文件行数 排序
        sheet.set_rows rows

        sheet.set_row []
        sheet.set_row []
        sheet.set_headings ['模型','类',
                            '模型lines','模型文件',
                            '控制器文件','控制器lines',
                            '模型方法size','模型方法',
                            '字段size','字段',
                            '视图size', '视图',
                            'action-size','actions']
      end
    end
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
  def camelize name
    name.camelize
  end
  def name
    @@root.name
  end
  def path
    @@root.path
  end


  def self.save_info
    @@p ||= Ld::Project.new(Rails.root.to_s)

  end

  def self.get_routes
    @@p ||= Ld::Project.new(Rails.root.to_s)
    file = Ld::File.new @@p.config.path + '/routes.txt'
    system "rake routes > #{file.path}"
    file.lines.map{|line| arr = line.split(' '); arr.size == 3 ? arr.unshift(nil) : arr}
    t.headings = ['controller', 'action', 'type']
    arrs.map{|arr| controller,action = arr[3].split('#'); [controller, action, arr[1]]}
        .each{|arr| t.add_row arr}
  end

  def self.p model = :all
    @@p ||= Ld::Project.new(Rails.root.to_s)

    t = Terminal::Table.new
    case model.to_s
      when 'all'
        t.title = "project:#{@@root.name}"
        t.headings = ['models', 'views', 'controllers', 'routes']
        t.add_row [@@p.models.size, @@p.views.size, @@p.controllers.size, @@p.routes.lines.size]
      when 'models'
        t.title = 'models'
        t.headings = ['name', 'action-size', 'line-size', 'routes']
        @@p.models.map{|f| [f.name.split('.')[0], f.lines.map{|l| l if l.match(/def /)}.compact.size, f.lines.size, nil] }
            .sort{|a,b| b[1]-a[1]}.each{|i| t.add_row i}
      when 'controllers'
        t.title = 'controllers'
        t.headings = ['name', 'action-size', 'line-size']
        @@p.controllers.map{|f| [f.name.split('.')[0], f.lines.map{|l| l if l.match(/def /)}.compact.size, f.lines.size] }
            .sort{|a,b| b[1]-a[1]}.each{|i| t.add_row i}
      when 'views'
        t.title = 'views'
        t.headings = ['name', 'file-size', 'html']
        @@p.app.views.children('shared')
            .map{|f| htmls = f.search(/.html/);[f.name, htmls.size, htmls.map{|f2| f2.name.split('.')[0]}.join(' ')]}
            .sort{|a,b| b[1]-a[1]}
            .each{|arr| t.add_row arr}
      when 'routes'
        file = Ld::File.new @@root.path + '/routes.txt'
        if !file.exist?
          system "rake routes > #{@@root.path + '/routes.txt'}"
        end
        arrs = file.lines.map{|l| lines = l.split(' '); lines.size == 3 ? lines.unshift(nil) : lines}
        arrs.delete_at 0
        t.title = 'routes'
        t.headings = ['controller', 'action', 'type']
        arrs.map{|arr| controller,action = arr[3].split('#'); [controller, action, arr[1]]}
            .each{|arr| t.add_row arr}
      else
        puts '(models/controllers/views)'
        return
    end
    puts t
  end

end