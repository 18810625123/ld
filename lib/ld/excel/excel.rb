require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'

class Ld::Excel
  attr_accessor :excel,:path,:basename,:sheets,:sheet,:scope_arrs,:mappings,:bean,:beans
  attr_accessor :format

  @@hz        ||= ".xls"
  ZIMU      ||= {}

  if ZIMU.empty?
    flag = 'A'
    0.upto(9999) do |i|
      ZIMU.store(flag,i)
      flag = flag.succ
    end
  end

  # 构造函数,如果未传path则是创建一个新的excel,   如果传了path,则打开这个excel,不过打开前会验证后缀与是否存在
  def initialize(path = nil)
    if path!=nil
      if path.match(/.xls$/)!=nil
        if File::exist? path
          @excel = Spreadsheet.open path
          @path = path
          puts "打开文件:  #{path}"
        else
          raise "文件不存在:  #{path}"
        end
      else
        raise "只能打开.xls结尾的文件"
      end
    else
      @excel = Spreadsheet::Workbook.new
      puts "创建新的Excel实例"
    end
    @sheets = {}
    @sheet = nil
  end

  def self.open(path)
    self.new(path)
  end

  # 获取一页
  def open_sheet sheet_name
    @sheet = @excel.worksheet sheet_name
    if @sheet == nil
      raise "未找到 sheet #{sheet_name}"
    else
      # puts "sheet #{sheet_name}"
    end
    self
  end

  # 获取所有页
  def get_sheets
    @sheets = @excel.worksheets
    puts "返回 #{@sheets.size} 页"
    self
  end

  # 读一个单元格
  def read_location(location,parse = true)
    l = Ld::Excel.parse_location(location)
    unit = read_unit_by_xy(l[:r],l[:c],parse)
    # puts ""
  end

  # 读一个单元格2
  def read_sheet_location(location,parse = true)
    open_sheet location.split('?')[0]
    read_location location.split('?')[1]
  end


  # 刷新excel中的sheet
  def open_new
    excel_new = Ld::Excel.open @path
  end

  # 读很多个location链,返回二维数组
  def read_location_list_arr(location_list_arr_str)
    units_arr = []
    location_list_arr_str.split(',').each do |location_list|
      units = read_location_list(location_list)
      units_arr << units
    end
    units_arr
  end

  # 读取一个location链 ,返回一维数组
  def read_sheet_locations(locations_config,parse = true)
    unit_list = []
    open_sheet locations_config.split('?')[0]
    locations_config.split('?')[1].split('.').each do |location|
      l = Ld::Excel.parse_location(location)
      unit = read_unit_by_xy(l[:r],l[:c],parse)
      unit_list << unit
    end
    unit_list
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

  def flush
    Ld::Excel.new self.path
  end

  def parse_del_to_hash address, scope
    arr = address.split '-'
    arr = arr[1..arr.size-1]
    start_row_num = scope.scan(/\d/).join[0..1]# 首行行号
    location = Ld::Excel.parse_location(scope.split(':')[0])
    hash = {}
    del_rows = []
    address.each do |del_row_num|# 去除行行号
      rows << del_row_num.to_i - start_row_num.to_i# 去除行行号 - 首行行号 = 数组角标位置
    end
    hash.store(:rows,jiang(rows))
    hash
  end

  # 解析一个excel location
  def self.parse_location location
    if location and location.class == String
      location.upcase!
      {
          :x => ZIMU[location.scan(/[A-Z]+/).join].to_i,
          :y => (location.scan(/[0-9]+/).join.to_i - 1)
      }
    else
      ms.puts_fail "location为空或不是String类型,无法解析"
    end
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

  def map_add map, add
    if is_number? add
      map[:y] << add
    else
      map[:x] << add
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

  def is_number? str
    if str.to_i.to_s == str.to_s
      return true
    end
    false
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
        rows << ["#{x}_#{y}", ZIMU[x], y.to_i - 1]
      end
      arrs << rows
    end
    return arrs
  rescue
    puts "生成map时发生错误: #{$!}"
    puts $@
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

  # 先打开一个sheet页,再读scope范围数据
  # params?b13:m27-g.j.k.(14:18)
  def read full_scope, simple = true, filter_nil = false
    if full_scope.include?('?')
      sheet_name = full_scope.split('?')[0]
      if sheet_name
        open_sheet sheet_name
      else
        raise "sheetname为nil"
      end
      address_str = full_scope.split('?')[1]
      map = generate_map address_str
      data_arrs = read_map map, simple
      if data_arrs.size == 0
        puts "没有任何内容的区域!  #{full_scope}"
      else
        puts "#{full_scope}"
      end
      # 除去不完整数据
      if filter_nil == true
        (data_arrs.size - 1).downto(0) do |i|
          arr = data_arrs[i]
          if arr[0] == nil or arr[1] == nil
            data_arrs.delete_at i
          end
        end
      end
      return data_arrs
    else
      raise "缺少?,需要在'?'左边指定sheet的名称"
    end
  end

  def read_map arrs, simple = true
    @scope_arrs = []
    arrs.each do |arr|
      rows = []
      arr.each do |a|
        if simple
          rows << read_unit_by_xy(a[1], a[2], true)
        else
          rows << {:index => a[0], :value => read_unit_by_xy(a[1], a[2], true)}
        end
      end
      @scope_arrs << rows
    end
    @scope_arrs
  end

  # 排序
  def jiang arr
    0.upto(arr.size - 2) do |i|
      (i+1).upto(arr.size - 1) do |j|
        if arr[i] < arr[j]
          arr[i] = arr[i] + arr[j]
          arr[j] = arr[i] - arr[j]
          arr[i] = arr[i] - arr[j]
        end
      end
    end
    arr
  end

  def sheng arr
    0.upto(arr.size - 2) do |i|
      (i+1).upto(arr.size - 1) do |j|
        if arr[i] > arr[j]
          arr[i] = arr[i] + arr[j]
          arr[j] = arr[i] - arr[j]
          arr[i] = arr[i] - arr[j]
        end
      end
    end
    arr
  end

  # 保存文件
  def save path
    if File.exist? path
      @excel.write path
      puts "保存覆盖了一个同名文件   #{@path}"
    else
      @excel.write path
      puts "保存到:     #{path}"
    end
    self
  end

  def new_sheet name
    Ld::Sheet.new @excel, name
  end

  def write_sheet sheet_name, &block
    @sheet = new_sheet sheet_name
    block.call @sheet
    @sheet.save
  end

  def self.create hash, &block
    excel = Ld::Excel.new
    block.call excel
    excel.save hash[:file_path]
  end

  def self.test
    Ld::Excel.create '/Users/liudong/Desktop/abss.xls' do |excel|
      ['sh1','sh2','发有3'].each do |sheet_name|
        excel.write_sheet sheet_name do |sheet|
          sheet.set_format({color: :green, font_size: 22, font: '宋体'})
          sheet.set_headings ['a','b']
          sheet.set_point 'c5'
          (5..22).to_a.each do |i|
            sheet.add_row i.times.map{|j| '村腰里 是'}
          end
        end
      end
    end
  end
end

