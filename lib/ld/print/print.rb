require 'terminal-table'

class Ld::Print

  def initialize models
    @models = models
  end

  def self.p models,fields
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

end