class Ld::Sheet
  attr_accessor :excel, :sheet

  ABSCISSA = {}
  if ABSCISSA.empty?
    zm = 'A'
    ABSCISSA[zm] = 0
    19999.times{|i| ABSCISSA[zm.succ!] = i+1}
  end

  def initialize excel, name, type = 'new'
    raise "name为 nil" if !name
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
        raise "#{name} 不存在" if !@sheet
    end
    @format = @sheet.default_format
  end

  def read address_str, simple = false
    map = generate_map address_str
    arrs = read_map map, simple
    if arrs.size == 0
      puts "没有任何内容的区域!  #{address_str}"
    else
      puts "#{address_str}"
    end
    arrs
  end

  # simple 带不带坐标index数据
  def read_map arrs, simple
    @scope_arrs = []
    arrs.each do |arr|
      rows = []
      arr.each do |a|
        if simple
          rows << {:index => a[0], :value => read_unit_by_xy(a[1], a[2], true)}
        else
          rows << read_unit_by_xy(a[1], a[2], true)
        end
      end
      @scope_arrs << rows
    end
    @scope_arrs
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

  # 用坐标解析一个excel scope
  def generate_map address_str
    map = {:x => [], :y => []}
    config = parse_address address_str
    if config[:scope]
      if config[:scope].include? ':'
        # map初始化
        arr = config[:scope].split(':')
        if config[:scope].scan(/[0-9]+/).join == ''
          map_adds(map, ab_to(arr[0].scan(/[A-Z]+/).join, arr[1].scan(/[A-Z]+/).join))
        elsif config[:scope].scan(/[A-Z]+/).join == ''
          map_adds(map, ab_to(arr[0].scan(/[0-9]+/).join, arr[1].scan(/[0-9]+/).join))
        else
          map_adds(map, ab_to(arr[0].scan(/[0-9]+/).join, arr[1].scan(/[0-9]+/).join))
          map_adds(map, ab_to(arr[0].scan(/[A-Z]+/).join, arr[1].scan(/[A-Z]+/).join))
        end
        # map 添加
        if config[:add_str]
          config[:add_str].split(',').each do |add|
            if add.include? ":"
              map_adds(map, ab_to(add.split(':')[0], add.split(':')[1]))
            else
              map_add map, add
            end
          end
        end
        # map 减小
        if config[:min_str]
          config[:min_str].split(',').each do |min|
            if min.include? ":"
              map_mins(map, ab_to(min.split(':')[0], min.split(':')[1]))
            else
              map_min map, min
            end
          end
        end
      else
        raise "scope 没有 ':' 无法解析"
      end
    else
      raise "scope == nil"
    end
    map[:x].uniq!
    map[:y].uniq!
    arrs = []
    map[:y].each do |y|
      rows = []
      map[:x].each do |x|
        rows << ["#{x}_#{y}", ABSCISSA[x], y.to_i - 1]
      end
      arrs << rows
    end
    return arrs
  rescue
    puts "生成map时发生错误: #{$!}"
    puts $@
  end

  def ab_to a, b
    type = nil
    if is_number?(a) == true and is_number?(b) == true
      type = 'y'
      case a.to_i <=> b.to_i
        when 1
          return [type, (b..a).to_a]
        when -1
          return [type, (a..b).to_a]
        when 0
          return [type, [a]]
      end
    elsif is_number?(a) == false and is_number?(b) == false
      type = 'x'
      case a <=> b
        when 1
          return [type, (b..a).to_a]
        when -1
          return [type, (a..b).to_a]
        when 0
          return [type, [a]]
      end
    else
      raise "解析excel配置范围时,':'两边必须要么都是字母,要么都是数字!"
    end
  end

  def map_mins map, mins
    case mins[0]
      when 'x'
        mins[1].each do |min|
          map[:x].delete min
        end
      when 'y'
        mins[1].each do |min|
          map[:y].delete min
        end
    end
  end

  def map_min map, min
    if is_number? min
      map[:y].delete min
    else
      map[:x].delete min
    end
  end

  def map_adds map, adds
    case adds[0]
      when 'x'
        adds[1].each do |add|
          map[:x] << add
        end
      when 'y'
        adds[1].each do |add|
          map[:y] << add
        end
    end
  end

  def is_number? str
    if str.to_i.to_s == str.to_s
      return true
    end
    false
  end

  def map_add map, add
    if is_number? add
      map[:y] << add
    else
      map[:x] << add
    end
  end

  # 解析范围配置
  def parse_address address
    hash = {}
    if address
      address.upcase!
    else
      raise "address 为 nil"
    end
    if address.split('+').size > 2
      raise "'+'号只能有1个"
    end
    if address.split('-').size > 2
      raise "'-'号只能有1个"
    end
    if address.include?('+')
      a = address.split('+')[0]
      b = address.split('+')[1]
      if a.include?('-')
        hash.store :scope, a.split('-')[0]
        hash.store :min_str, a.split('-')[1]
        hash.store :add_str, b
      else
        hash.store :scope, a
        if b.include?('-')
          hash.store :min_str, b.split('-')[1]
          hash.store :add_str, b.split('-')[0]
        else
          hash.store :add_str, b
        end
      end
    else
      if address.include?('-')
        hash.store :scope, address.split('-')[0]
        hash.store :min_str, address.split('-')[1]
      else
        hash.store :scope, address
      end
    end
    hash
  end

  def self.open excel, name
    self.new excel, name, 'open'
  end

  def self.create excel, name
    self.new excel, name, 'new'
  end

  def save
    l = parse_location @point
    raise '保存sheet必须要有内容,请 set_rows' if !@rows
    raise '保存sheet必须要有name,请 set_rows' if !@name
    @rows.unshift @headings if @headings
    @sheet.default_format = @format
    @rows.each_with_index do |row,r|
      row.each_with_index do |data,c|
        write_unit_by_xy(r+l[:y],c+l[:x],data)
      end
    end
    self
  end

  # 解析一个 content_url
  def parse_location location_str
    raise "无法解析excel坐标,坐标需要是String,不能是#{location_str.class.to_s}" if location_str and location_str.class != String
    location_str.upcase!
    return {:x => ABSCISSA[location_str.scan(/[A-Z]+/).join].to_i, :y => (location_str.scan(/[0-9]+/).join.to_i - 1)}
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

  # 将一维数组写到表中,可写成列,也可以写成行
  def write_arr_to_point(arr, rank = '|', point = "a1")
    l = Ld::Excel.parse_location(point)
    if rank == '|' or rank == 'col'
      arr.each_with_index do |data,r|
        # 坚写,行动列不动
        write_unit_by_xy(l[:r]+r,l[:c],data)
      end
    elsif rank == '-' or rank == 'row'
      arr.each_with_index do |data,c|
        # 横写,列动行不动
        write_unit_by_xy(l[:r],l[:c]+c,data)
      end
    else
      raise "横写rank |  竖写rank -   无法识别#{rank}"
    end
    self
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
