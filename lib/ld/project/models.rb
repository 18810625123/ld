class Ld::Models
  attr_accessor :headings, :rows, :models

  def initialize root, tables
    @root = root
    @tables = tables
    parse
  end

  def parse
    rows =  []
    model_files = @root.app.models.search_files(/.rb$/).map{|m|
      m if @tables.tables.include?(m.name.split('.')[0].pluralize)
    }.compact
    @rows = model_files.map{ |file|
      name    = file.name.split('.')[0]
      lines   = file.lines
      methods_full = lines.map{|l| l.split('def ')[1] if l.match(/def /)}.compact
      methods = methods_full.map{|method_full| method_full.split(' ')[0]}
      instance = name.camelize.constantize.new
      data_count = name.camelize.constantize.count
      fields = instance.attributes.keys
      [name,name.pluralize,name.camelize,data_count,lines.size,file.path,methods.size,methods.join(','),fields.join(','),fields.size]
    }.compact.sort{|a,b| b[2] <=> a[2]} # 按 模型文件行数 排序
    @models = @rows.map{|arr| arr[0]}.uniq
    @headings = ['模型名','表名','类','数据数量','行数','path', '方法数','所有方法', '所有字段','字段数量']
  end


end
