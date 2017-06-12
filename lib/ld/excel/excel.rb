require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'

class Ld::Excel
  attr_accessor :excel, :path

  def initialize path = nil
    if path
      if path.match(/.xls$/)
        if File::exist? path
          @excel = Spreadsheet.open path
          @path = path
        else
          raise "File does not exist:  #{path}"
        end
      else
        raise "Can only read .xls!"
      end
    else
      @excel = Spreadsheet::Workbook.new
    end
  end

  #= 作用 打开一个xls文件,返回Ld::Excel实例
  def self.open path
    self.new path
  end
  
  #= 作用 写excel(创建新的xls文件)
  def self.write path, &block
    if path.class == Hash
      path = path[:file_path]
    end
    excel = Ld::Excel.new
    block.call excel
    excel.save path
  end

  #= 作用 write的同名方法
  def self.create path, &block
    self.write path, &block
  end

  #= 作用 读xls文件中的内容,二维数组
  #= 示例 Ld::Excel.read "Sheet1?A1:B2"
  def read params, show_location = false
    case params.class.to_s
      when 'String'
        shett_name, scope = params.split('?')
        @current_sheet = open_sheet shett_name
        @current_sheet.read scope, show_location
      when 'Hash'
        raise "Parameter error! \nnot find 'sheet'" if params[:sheet].nil?
        raise "Parameter error! \nnot find 'scope'" if params[:scope].nil?
        params[:location] = false if params[:location].nil?
        @current_sheet = open_sheet params[:sheet]
        @current_sheet.read params, params[:location]
    end
  end

  #= 作用 与read方法相同(但会多返回坐标数据)
  def read_with_location params
    read params, true
  end

  # 作用 如果xls文件内容有改变,可以刷新(会重新open一次,但这个方法不需要再传入参数了)
  def flush
    @excel = Ld::Excel.open @path
  end

  # 作用 保存(真正执行io写入操作)
  def save path
    puts "Covers a file: #{path}" if File.exist? path
    @excel.write path
    puts "Excel save success!"
    self
  rescue
    puts $!
    puts $@
    false
  end

  def new_sheet name
    Ld::Sheet.new @excel, name
  end

  def open_sheet name
    Ld::Sheet.open @excel, name
  end

  def write_sheet sheet_name, &block
    sheet = new_sheet sheet_name
    block.call sheet
    sheet.save
    true
  rescue
    puts $!
    puts $@
    false
  end

end

