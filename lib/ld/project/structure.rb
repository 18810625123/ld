class Ld::Project::Structure
  include Ld::Project::Parse
  attr_accessor :root, :name, :path

  def initialize path = Rails.root.to_s
    @root = Ld::File.new path
    @name = @root.name
    @path = @root.path
  end



  def generate path = "#{@root.path}/project.xls"
    Ld::Excel.create path do |excel|
      # sheet.set_format({color: :black, font_size: 14, font: '微软雅黑'})
      excel.write_sheet 'routes' do |sheet|
        @routes = parse_routes @root
        sheet.set_headings @routes[:headings]
        sheet.set_rows @routes[:rows]
      end
      excel.write_sheet 'tables' do |sheet|
        @tables = parse_schema @root
        sheet.set_headings @tables[:headings]
        sheet.set_rows @tables[:rows]
      end
      excel.write_sheet 'models' do |sheet|
        @models = parse_models @root
        sheet.set_headings @models[:headings]
        sheet.set_rows @models[:rows]
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


end