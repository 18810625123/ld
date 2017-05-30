class Ld::Views
  attr_accessor :headings, :rows

  def initialize root, models
    @root = root
    @models = models
    parse
  end

  def parse
    @rows = @root.app.views.search_files(/.html/).map{|v|
      dir_name = v.father.name
      model_name = @models.models.include?(dir_name.singularize) ? dir_name.singularize : nil
      [model_name,v.lines.size,dir_name,v.name,v.path]
    }.sort{|a,b| b[1] <=> a[1]}
    @headings = ['所属模型名','行数','文件夹名','文件名','path']
  end

  def find model_name
    @view_dirs.each do |view_dir|
      if view_dir.name == model_name.pluralize
        return Ld::View.new view_dir
      end
    end
    nil
  end

end
