class Ld::Models
  attr_accessor :headings, :rows, :models

  def initialize root, tables, table_hash
    @root = root
    @tables = tables
    @table_hash = table_hash
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
      data_count = nil#name.camelize.constantize.count
      fields = instance.attributes.keys
      relations = get_relations file.lines
      [
          name,name.pluralize,@table_hash[name],name.camelize,data_count,lines.size,file.path,methods.size,
          methods.join(','),fields.join(','),fields.size,
          relations[:has_many].size,relations[:belongs_to].size,relations[:has_one].size,
          relations[:has_many].join(",\n"),
          relations[:belongs_to].join(",\n"),
          relations[:has_one].join(",\n")
      ]
    }.compact.sort{|a,b| b[0] <=> a[0]} # 按 模型文件行数 排序
    @models = @rows.map{|arr| arr[0]}.uniq
    @headings = ['模型名','表名','comment','类','数据数量','行数','path', '方法数',
                 '所有方法', '所有字段','字段数量',
                 'has_many个数','belongs_to个数','has_one个数',
                 'has_many','belongs_to','has_one']
  end

  def get_relations lines
    relations = {has_many:[],belongs_to:[],has_one:[]}
    lines.each do |line|
    arr = line.split(' ')
      if ['has_many','belongs_to','has_one'].include? arr[0]
        model = arr[1].split(':')[1].split(',')[0]
        china = @table_hash[model.singularize]
        if !china
          if i = arr.index('class_name:')
            if class_name = arr[i+1]
              class_name = class_name.split('"')[1] if class_name.match(/"/)
              class_name = class_name.split("'")[1] if class_name.match(/'/)
              china = @table_hash[class_name.underscore]
            end
          end
        end
        relations[arr[0].to_sym] << "#{model}(#{china})"
      end
    end
    relations
  end

end
