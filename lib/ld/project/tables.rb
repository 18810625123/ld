class Ld::Tables

  attr_accessor :headings, :rows, :tables

  def initialize root, models
    @root = root
    @models = models
    parse
  end

  def parse
    tables = {}
    read_flag = false
    table = ""
    @root.find('db/schema.rb').lines.each do |l|
      if l.split(' ')[0] == 'end'
        read_flag = false
      end
      if l.split(' ')[0] == 'create_table'
        read_flag = true
        table = l.split('"')[1]
        tables[table] = []
      end
      if read_flag
        tables[table] << l
      end
    end
    rows = []
    tables.each do |table_name, lines|
      model_class = parse_class table_name
      lines.delete_at(0)
      lines.each do |line|
        hash = parse_line line
        if hash[:type] != 'index'
          if @models
            @model_name = @models.models.include?(table_name.singularize) ? table_name.singularize : nil
          end
          rows << [@model_name,table_name,hash[:field],hash[:type],hash[:comment],hash[:null],hash[:default],hash[:precision],hash[:limit]]
        end
      end
    end
    @headings = ['所属模型','表名','字段','字段类型','描述','空约束','默认值','精度位数','limit']
    @rows = rows.sort{|a,b| b[1] <=> a[1]}
    @tables = tables.keys
  end

  def parse_line line
    arr = line.split(' ')
    hash = {}
    if arr[0].match(/^t./)
      hash[:type]    = arr[0].split('.')[1]
      i = nil
      if hash[:type] == 'index'
        hash[:name]    = arr[i + 1] if i = arr.index('name:')
        hash[:unique]    = arr[i + 1] if i = arr.index('unique:')
        hash[:using]    = arr[i + 1] if i = arr.index('using:')
      else
        hash[:field]    = line.split('"')[1]
        hash[:null]    = arr[i + 1] if i = arr.index('name:')
        hash[:limit] = arr[i + 1] if i = arr.index('limit:')
        hash[:comment] = arr[i + 1].split('"')[1] if i = arr.index('comment:')
        hash[:default] = arr[i + 1] if i = arr.index('default:')
        hash[:precision] = arr[i + 1] if i = arr.index('precision:')
        hash[:precision] = arr[i + 1] if i = arr.index('precision:')
      end
      return hash
    else

    end
    return false
  end

  def parse_class table_name
    model_class = table_name.singularize.camelize.constantize
    return model_class
  rescue
    return nil
  end


end