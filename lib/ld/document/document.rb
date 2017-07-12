class Ld::Document

  attr_accessor :doc

  # 作用 读一个rb文件生成api数据
  def initialize file
    @doc = {}
    @lines = file.lines
    @lines.each_with_index do |line, i|
      arr = line.split(' ')
      if arr.delete_at(0) == 'def'
        notes = get_notes(@lines, i)
        if notes.size > 0
          method = arr.delete_at(0)
          @doc[method] = {
              params:arr.join(' '),
              notes:notes
          }
        end
      end
    end
  end

  def get_notes lines, i
    notes = []
    (i-1).downto(0) do |j|
      arr = lines[j].split(' ')
      if arr[0] == '#='
        notes << {title:arr[1], note:arr[2..(arr.size)].join(' ')}
      else
        return notes
      end
    end
    notes
  end


  def class_name
    @lines.each do |line|
      if line.split(' ')[0] =='class'
        return line.split(' ')[1]
      end
    end
    return nil
  end

  def self.write_readme readme_path = '/Users/liudong/ruby/my_gems/ld/README2.md'
    docs = Ld::File.open('/Users/liudong/ruby/my_gems/ld/lib/ld').search_regexp(/.rb$/).map{|f| Ld::Document.new f}
    arr = ["## API\n\n\n"]
    docs.each do |doc|
      if !doc.doc.empty?
        arr << "### #{doc.class_name}"
        # arr << "```ruby"
        doc.doc.each do |k, v|
          arr << "* `#{k} #{v[:params]}`"
          v[:notes].each do |note|
            arr << " * #{note[:title]}:#{note[:note]}"
          end
          arr << ""
        end
        # arr << "```"
      end
    end
    File.open readme_path,'w' do |file|
      arr.each do |line|
        file.puts line
      end
      file.close
    end
  end

end

