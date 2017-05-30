class Ld::Sheet

  def initialize excel, name
    @excel = excel
    @name = name
    @point = 'a1'
    @rows = []
    @headings = nil
    @sheet = excel.create_worksheet :name => name
    @format = @sheet.default_format
  end

  def save
    l = Ld::Excel.parse_location @point
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
      puts '有一个单元格是数组格式,已经转化成字符串'
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
