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

  def read scope, show_location = false
    raise "scope params is nil" if !scope
    map = parse_scope_to_map scope
    read_arrs map, show_location
  end

  def parse_string_scope scope
    hash = {}
    scope.upcase!
    raise "params error! \n'+' 只能有1个" if scope.split('+').size > 2
    raise "params error! \n'-' 只能有1个" if scope.split('-').size > 2
    if scope.include? '+'
      hash[:scope], other = scope.split('+')
      if other.include? '-'
        hash[:adds], hash[:mins] = other.split('-')
      else
        hash[:adds] = other
      end
    else
      if scope.include? '-'
        hash[:scope], hash[:mins] = scope.split('-')
      else
        hash[:scope] = scope
      end
    end
    hash
  end

  def parse_scope_to_map scope
    scope = parse_string_scope scope if scope.class == String
    raise "params lack fields ':scope'!" if !scope[:scope]
    raise "params syntax error! lack ':'" if !scope[:scope].match(/:/)
    raise "params syntax error! ':' 只能有1个" if scope[:scope].split(':').size > 2
    a, b = scope[:scope].split(':').map{|point| parse_point point}
    cols = (a[:character]..b[:character]).to_a
    rows = (a[:number]..b[:number]).to_a
    maps_add rows, cols, scope[:adds].upcase if scope[:adds]
    maps_min rows, cols, scope[:mins].upcase if scope[:mins]

    if scope[:mins]
      raise "mins 参数只能是 String" if scope[:mins].class != String
    end
    rows = rows.uniq.sort
    cols = cols.uniq.sort
    maps = rows.map do |row|
      cols.map do |col|
        col_i = ABSCISSA[col]
        raise "不存在这个列 \n'#{col}'" if !col_i
        {
            location:"#{col}#{row}",
            row:row,
            col:col_i
        }
      end
    end
    # 调试
    # maps.each do |arr|
    #   puts arr.map{|a| a[:location]}.to_s
    # end
    maps
  end

  def maps_add rows, cols, adds
    raise "adds 参数只能是 String" if adds.class != String
    add_arr = adds.split(',').map do |add|
      if add.match(/:/)
        raise "add params syntax error! \n'#{add}'" if add.split(':').size > 2
        a, b = add.split(':')
        (a..b).to_a
      else
        add
      end
    end
    add_arr.flatten.each do |add|
      if is_row? add
        rows << add.to_i
      else
        cols << add.upcase
      end
    end
  end

  def maps_min rows, cols, mins
    raise "mins 参数只能是 String" if mins.class != String
    min_arr = mins.split(',').map do |min|
      if min.match(/:/)
        raise "min params syntax error! \n'#{min}'" if min.split(':').size > 2
        a, b = min.split(':')
        (a..b).to_a
      else
        min
      end
    end
    min_arr.flatten.each do |min|
      if is_row? min
        rows.delete min.to_i
      else
        cols.delete min.upcase
      end
    end
  end

  # show_location 带不带坐标index数据
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

  # 通过x,y坐标获取unit内容
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

  def is_row? row
    if row.to_i.to_s == row.to_s
      return true
    end
    false
  end

  def self.open excel, name
    self.new excel, name, 'open'
  end

  def self.create excel, name
    self.new excel, name, 'new'
  end

  def save
    point = parse_point @point
    raise '保存sheet必须要有内容,请 set_rows' if !@rows
    raise '保存sheet必须要有name,请 set_rows' if !@name
    @rows.unshift @headings if @headings
    @sheet.default_format = @format
    @rows.each_with_index do |row, r|
      row.each_with_index do |unit, c|
        x = point[:number] + r
        y = ABSCISSA[point[:character]] + c
        write_unit_by_xy x, y, unit
      end
    end
    self
  end

  # 解析一个 content_url
  def parse_point point
    raise "无法解析excel坐标,坐标需要是String,不能是#{point.class.to_s}" if point.class != String
    point.upcase!
    characters = point.scan(/[A-Z]+/)
    raise "parse point error! \n'#{point}'" if characters.size != 1
    numbers = point.scan(/[0-9]+/)
    raise "parse point error! \n'#{point}'" if numbers.size != 1
    {:character => characters[0], :number => numbers[0].to_i}
  end

  def set_rows rows
    raise '必须是一个数组且是一个二维数组' if rows.class != Array && rows.first.class != Array
    @rows = rows
  end

  def set_headings headings
    if headings
      raise 'headings 必须是一个数组' if headings.class != Array
      @headings = headings
    else
      @headings = nil
    end
  end

  def set_row row
    raise 'add_row 传入的必须是一个数组' if row.class != Array
    @rows << row
  end

  # 通过xy坐标往unit写内容
  def write_unit_by_xy x, y, unit
    if unit.class == Array
      unit = unit.to_s
      puts '提示: 有一个单元格的内容是Array, 它被当成字符串写入'
    end
    @sheet.row(x)[y] = unit
  end

  def set_color color
    @format.font.color = color
  end

  def set_font_size size
    raise 'size 必须是一个整数' if size.class != Fixnum
    @format.font.size  = size
  end

  def set_font font
    @format.font.name = font
  end

  def set_weight weight
    @format
  end

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
