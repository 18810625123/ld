class Ld::Project

  attr_accessor :root, :tables, :models, :controllers, :views, :routes

  def initialize path = Rails.root.to_s
    @root = Ld::File.new path
  end

  def parse_project
    @routes = Ld::Routes.new @root
    @tables = Ld::Tables.new @root, nil
    @models = Ld::Models.new @root, @tables
    @tables = Ld::Tables.new @root, @models
    @views = Ld::Views.new @root, @models
    @controllers = Ld::Controllers.new @root, @models
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
      excel.write_sheet 'views' do |sheet|
        sheet.set_headings @views.headings
        sheet.set_rows @views.rows
      end
      excel.write_sheet 'controllers' do |sheet|
        sheet.set_headings @controllers.headings
        sheet.set_rows @controllers.rows
      end
    end
  end


  def camelize name
    name.camelize
  end


end