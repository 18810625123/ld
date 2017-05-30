class Ld::Tables

  attr_accessor :headings, :rows, :table_names

  def initialize project
    @project = project
    root = @project.root
    tables = {}
    read_flag = false
    table = ""
    root.db.find('schema.rb').lines.each do |l|
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
          rows << [table_name, model_class.to_s,
                   hash[:field],hash[:type],hash[:comment],hash[:null],hash[:default],hash[:precision],hash[:limit]
          ]
        end
      end
    end
    # rows.sort{|a,b| a[0] <=> b[0]} 排序
    @headings = ['table','model','field','type','comment','null','default','precision','limit']
    @rows = rows
    @table_names = tables.keys
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