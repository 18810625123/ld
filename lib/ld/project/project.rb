class Ld::Project

  attr_accessor :root, :name, :path, :tables, :models, :controllers, :views, :routes

  def initialize path = Rails.root.to_s
    @root = Ld::File.new path
    @name = @root.name
    @path = @root.path
    @models = @root.app.models
    @views = @root.app.views
    @controllers = @root.app.controllers

  end

  # def ds_fs
  #   pluralize
  #   singularize
  # end

  def parse_project
    @routes = Ld::Routes.new self
    @tables = Ld::Tables.new self
    @models = Ld::Models.new self,@tables
  end

  def parse_mdoels table_names
    rows = table_names.map{|table_name|
      model_class = parse_class table_name
      if model
        instance = model_class.new
        fields = instance.attributes.keys

        [table_name, fields.size, model_class.count, ]
      end
    }.compact.sort{|a,b| a[1] <=> b[1]}
    {
        :headings => ['表名','字段数量','数据条数','has_many','has_one','belongs_to','valid','模型path','控制器path','null','default','precision','limit'],
        :rows => rows,
    }
  end

  def to_xls path = "#{@root.path}/project.xls"
    parse_project
    Ld::Excel.create path do |excel|
      # sheet.set_format({color: :black, font_size: 14, font: '微软雅黑'})
      excel.write_sheet 'routes' do |sheet|
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
    end
  end


  def camelize name
    name.camelize
  end


end