require 'terminal-table'

class Ld::Print

  #= 作用 格式化打印模型数组
  def self.p models, fields
    t = Terminal::Table.new
    t.title = models.first.class.to_s
    fields = (fields.class == Array ? fields : fields.split(',')).map{|f| f.rstrip.lstrip}
    t.headings = fields
    models.map { |model|
      fields.map { |field|
        value = model.send field
        value = value.strftime("%Y/%m/%d %H:%M:%S") if [Date, Time, DateTime, ActiveSupport::TimeWithZone].include? value.class
        value
      }
    }#.sort{|a,b| a[2] <=> b[2]}
        .each{|row| t.add_row row}
    puts t
  end

  def self.print hash
    t = Terminal::Table.new
    t.title = hash[:title]
    t.headings = hash[:headings]
    t.rows = hash[:rows]
    puts t
  end

  def self.ls dir
    t = Terminal::Table.new
    t.title = "目录列表:#{dir.path}"
    t.headings = ["name","type","size","permission"]
    t.rows = dir.children.map{|f| [f.name, f.type, f.size, f.mode] if f.name[0] != '.'}.compact.sort{|a,b| a[1] <=> b[1]}
    puts t
  end

end
