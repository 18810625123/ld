class Ld::Project

  attr_accessor :root, :tables, :models, :controllers, :views, :routes, :table_hash

  def initialize table_hash = {}, project_root_path = Rails.root.to_s
    @root = Ld::File.new project_root_path
    @table_hash = table_hash
    @schema = @root.db.find('schema.rb')
    raise "schema.rb文件不存在\n请运行命令(rake db:schema:dump)或手动添加此文件" if @schema.nil?
    raise "schema.rb文件是空的\n请运行命令(rake db:schema:dump)或手动添加此文件" if @schema.lines.size == 0
    parse_project
  end

  def parse_project
    @tables = Ld::Tables.new @root, nil
    @models = Ld::Models.new @root, @tables, @table_hash
    @routes = Ld::Routes.new @root, @models
    @tables = Ld::Tables.new @root, @models
    @views = Ld::Views.new @root, @models
    @controllers = Ld::Controllers.new @root, @models
  end

  def print model_name, type = :relations
    model_name = model_name.to_s
    if !@models.models.include? model_name
      puts "不存在 #{model_name}"
      return false
    end

    title_str = "#{model_name.camelize}(#{@table_hash[model_name]})"
    type = type.to_sym
    case type
      when :fields
        fs = '字段,字段类型,描述,空约束,默认值,精度位数,limit'.split(',')
        indexs = fs.map{|f| @tables.headings.index(f)}.compact
        rows = []
        @tables.rows.select{|a| a[0]==model_name}.each{|arr| rows << indexs.map{|i| arr[i]} }
        puts Terminal::Table.new(
                 :title => "#{title_str}:字段解释",
                 :headings => fs,
                 :rows => rows
             )
      when :relations
        fs = 'has_many,belongs_to,has_one'.split(',')
        indexs = fs.map{|f| @models.headings.index(f)}.compact
        rows = []
        @models.rows.select{|a| a[0]==model_name}.each{|arr|
          rows << indexs.map{|i| arr[i]}
        }
        puts Terminal::Table.new(
                 :title => "#{title_str}:关联关系",
                 :headings => fs,
                 :rows => rows
             )
      when :routes
        fs = '控制器,action,请求类型,URI,帮助方法'.split(',')
        indexs = fs.map{|f| @routes.headings.index(f)}.compact
        rows = []
        @routes.rows.select{|a| a[0]==model_name}.each{|arr| rows << indexs.map{|i| arr[i]} }
        puts Terminal::Table.new(
                 :title => "#{title_str}:路由",
                 :headings => fs,
                 :rows => rows
             )
      when :views
        fs = '文件夹名,行数,文件名,path'.split(',')
        indexs = fs.map{|f| @views.headings.index(f)}.compact
        rows = []
        @views.rows.select{|a| a[0]==model_name}.each{|arr| rows << indexs.map{|i| arr[i]} }
        puts Terminal::Table.new(
                 :title => "#{title_str}:视图",
                 :headings => fs,
                 :rows => rows
             )
      when :controllers
        fs = 'action个数,文件行数,所有action'.split(',')
        indexs = fs.map{|f| @controllers.headings.index(f)}.compact
        rows = []
        @controllers.rows.select{|a| a[0]==model_name}.each{|arr| rows << indexs.map{|i| arr[i]} }
        puts Terminal::Table.new(
                 :title => "#{title_str}:控制器",
                 :headings => fs,
                 :rows => rows
             )
    end

    true
  end

  def delete_rows_index
    @routes.rows.delete_at 0
    @tables.rows.delete_at 0
    @models.rows.delete_at 0
    @views.rows.delete_at 0
    @controllers.rows.delete_at 0
  end

  def to_xls path = {:file_path => "#{@root.path}/project.xls"}
    Ld::Excel.create path do |excel|
      excel.write_sheet 'routes' do |sheet|
        sheet.set_format({color: :red, font_size: 14, font: '微软雅黑'})
        sheet.set_headings @routes.headings
        sheet.set_rows @routes.rows
      end
      excel.write_sheet 'tables' do |sheet|
        sheet.set_headings @tables.headings
        sheet.set_rows @tables.rows
      end
      excel.write_sheet 'models' do |sheet|
        sheet.set_headings @models.headings
        sheet.set_rows @models.rows
      end
      excel.write_sheet 'views' do |sheet|
        sheet.set_headings @views.headings
        sheet.set_rows @views.rows
      end
      excel.write_sheet 'controllers' do |sheet|
        sheet.set_headings @controllers.headings
        sheet.set_rows @controllers.rows
      end
    end
    #delete_rows_index
  end

  def add_bug

  end



end