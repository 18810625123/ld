class Ld::Sheet
  attr_accessor :excel, :sheet

  ABSCISSA = {}
  if ABSCISSA.empty?
    zm = 'A'
    ABSCISSA[zm] = 0
    19999.times{|i| ABSCISSA[zm.succ!] = i+1}
  end

  def initialize excel, name, type = 'new'
    raise "sheet name is nil" if !name
    @excel = excel
    @name = name
    case type
      when 'new'
        @sheet = excel.create_worksheet :name => name
        @point = 'a1'
        @headings = nil
        @rows = []
      when 'open'
        @sheet = excel.worksheet name
        raise "sheet '#{name}' not found!" if !@sheet
    end
    @format = @sheet.default_format
  end

  # 作用 读sheet页数据,返回二维数组
  def read scope, show_location = false
    raise "scope params is nil" if !scope
    map = read_scope_to_map scope
    read_arrs map, show_location
  end

  # 作用 解析范围参数
  def parse_string_scope scope
    PARAMETER_ERROR.hint_and_raise :scope, "'+' or '-' 只能存在1个" if scope.split('+').size > 2 or scope.split('-').size > 2
    hash = {}
    scope.upcase!
    if scope.include? '+'
      hash[:scope], other = scope.split('+')
      if other.include? '-'
        hash[:insert], hash[:delete] = other.split('-')
      else
        hash[:insert] = other
      end
    else
      if scope.include? '-'
        hash[:scope], hash[:delete] = scope.split('-')
      else
        hash[:scope] = scope
      end
    end
    hash
  end

  # 作用 使用范围参数构建maps(预读)
  def read_scope_to_map scope
    scope = parse_string_scope scope if scope.class == String
    PARAMETER_ERROR.hint_and_raise :scope, "缺少scope参数,或':',或':'存在多个" if !scope[:scope] or !scope[:scope].match(/:/) or scope[:scope].split(':').size > 2
    a, b = scope[:scope].split(':').map{|point| parse_point point}
    cols = (a[:character]..b[:character]).to_a
    rows = (a[:number]..b[:number]).to_a
    insert_maps rows, cols, scope[:insert].upcase if scope[:insert]
    delete_maps rows, cols, scope[:delete].upcase if scope[:delete]

    if scope[:delete]
      raise "delete 参数只能是 String" if scope[:delete].class != String
    end
    rows = rows.uniq.sort
    cols = cols.uniq.sort
    maps = rows.map do |row|
      cols.map do |col|
        col_i = ABSCISSA[col]
        raise "不存在这个列 \n'#{col}'" if !col_i
        {
            location:"#{col}#{row}",
            row:row - 1,
            col:col_i
        }
      end
    end
    # 调试
    # maps.each do |arr|
    #   puts arr.map{|a| "#{a[:location]}(#{a[:row]}_#{a[:col]})"}.to_s
    # end
    maps
  end

  # 作用 多读一些行或列
  def insert_maps rows, cols, inserts
    raise "inserts 参数只能是 String" if inserts.class != String
    insert_arr = inserts.split(',').map do |insert|
      if insert.match(/:/)
        raise "insert params syntax error! \n'#{insert}'" if insert.split(':').size > 2
        a, b = insert.split(':')
        (a..b).to_a
      else
        insert
      end
    end
    insert_arr.flatten.each do |insert|
      if is_row? insert
        rows << insert.to_i
      else
        cols << insert.upcase
      end
    end
  end

  # 作用 少读一些行或列
  def delete_maps rows, cols, deletes
    raise "deletes 参数只能是 String" if deletes.class != String
    del_arr = deletes.split(',').map do |del|
      if del.match(/:/)
        raise "del params syntax error! \n'#{del}'" if del.split(':').size > 2
        a, b = del.split(':')
        (a..b).to_a
      else
        del
      end
    end
    del_arr.flatten.each do |del|
      if is_row? del
        rows.delete del.to_i
      else
        cols.delete del.upcase
      end
    end
  end

  # 作用 读二维数据(使用maps)
  def read_arrs map_arrs, show_location
    map_arrs.map do |map_arr|
      map_arr.map do |map|
        value = read_unit_by_xy map[:col], map[:row], true
        if show_location
          {map[:location] => value}
        else
          value
        end
      end
    end
  end

  # 作用 通过x,y坐标获取一个单元格的内容
  def read_unit_by_xy x, y, parse
    # puts "x: #{x}\ty: #{y}"
    unit = @sheet.row(y)[x]
    if unit.instance_of? Spreadsheet::Formula
      if parse
        return unit.value
      end
    end
    return unit
  end

  # 作用 判断要添加或要移除的是一行还是一列
  def is_row? row
    if row.to_i.to_s == row.to_s
      return true
    end
    false
  end

  # 作用 打开一个sheet
  def self.open excel, name
    self.new excel, name, 'open'
  end

  # 作用 创建一个sheet
  def self.create excel, name
    self.new excel, name, 'new'
  end

  # 作用 将数据写入sheet
  def save
    point = parse_point @point
    raise '保存sheet必须要有内容,请 set_rows' if !@rows
    raise '保存sheet必须要有name,请 set_rows' if !@name
    @rows.unshift @headings if @headings
    @sheet.default_format = @format
    @rows.each_with_index do |row, r|
      row.each_with_index do |unit, c|
        row = point[:number] + r - 1
        col = ABSCISSA[point[:character]] + c
        write_unit_by_xy row, col, unit
      end
    end
    self
  end

  # 作用 解析一个字符串坐标(如'A1')返回x,y坐标('A1'返回[0,0])
  def parse_point point
    raise "无法解析excel坐标,坐标需要是String,不能是#{point.class.to_s}" if point.class != String
    point.upcase!
    characters = point.scan(/[A-Z]+/)
    raise "parse point error! \n'#{point}'" if characters.size != 1
    numbers = point.scan(/[0-9]+/)
    raise "parse point error! \n'#{point}'" if numbers.size != 1
    {:character => characters[0], :number => numbers[0].to_i}
  end

  # 作用 在当前sheet中添加主体数据(传入二维数组),但不写入(只有调用Ld::Excel的实例方法save才会写入io)
  def set_rows rows
    raise '必须是一个数组且是一个二维数组' if rows.class != Array && rows.first.class != Array
    @rows = rows
  end

  #= 作用 在当前sheet的主体内容顶上方添加一个表头(传入二维数组),但不写入(只有调用Ld::Excel的实例方法save才会写入io)
  def set_headings headings
    if headings
      raise 'headings 必须是一个数组' if headings.class != Array
      @headings = headings
    else
      @headings = nil
    end
  end

  # 作用 在当前sheet的主体内容末尾添加一行数据(传入一维数组),但不写入(只有调用Ld::Excel的实例方法save才会写入io)
  def insert_row row
    raise 'insert_row 传入的必须是一个数组' if row.class != Array
    @rows << row
  end

  # 作用 通过x,y坐标往一个单元格中写入数据,但不写入(只有调用Ld::Excel的实例方法save才会写入io)
  def write_unit_by_xy x, y, unit
    if unit.class == Array
      unit = unit.to_s
      puts '提示: 有一个单元格的内容是Array, 它被当成字符串写入'
    end
    @sheet.row(x)[y] = unit
  end

  #= 作用 设置当前sheet页的字体颜色
  def set_color color
    @format.font.color = color
  end

  #= 作用 设置当前sheet页的字体大小
  def set_font_size size
    raise 'size 必须是一个整数' if size.class != Fixnum
    @format.font.size  = size
  end

  #= 作用 设置当前sheet页的字体
  def set_font font
    @format.font.name = font
  end

  #= 作用 设置当前sheet页的单元格宽度(暂时无效)
  def set_weight weight
    @format
  end

  #= 作用 设置当前sheet页的字体颜色
  def set_point point
    @point = point
  end

  def set_format hash
    set_color hash[:color]
    set_font_size hash[:font_size]
    set_font hash[:font]
  end

end

=begin

# <Spreadsheet::Format:0x007fe8297dba40
@bottom=:none,
@bottom_color=:builtin_black,
@cross_down=false,
@cross_up=false,
@diagonal_color=:builtin_black,
@font=
# <Spreadsheet::Font:0x007fe8285948a0
 @color=:black,
 @encoding=:iso_latin1,
 @escapement=:normal,
 @family=:none,
 @italic=false,
 @name="仿宋",
 @outline=false,
 @previous_fast_key=nil,
 @shadow=false,
 @size=11,
 @strikeout=false,
 @underline=:none,
 @weight=400>,
@horizontal_align=:center,
@indent_level=0,
@left=:none,
@left_color=:builtin_black,
@number_format="GENERAL",
@pattern=1,
@pattern_bg_color=:border,
@pattern_fg_color=:red,
@regexes=
{:date=>/[YMD]/,
 :date_or_time=>/[hmsYMD]/,
 :datetime=>/([YMD].*[HS])|([HS].*[YMD])/,
 :time=>/[hms]/,
 :number=>/([# ]|0+)/,
 :locale=>/(?-mix:\A\[\$\-\d+\])/},
=end
