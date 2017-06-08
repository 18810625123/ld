require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'

class Ld::Excel
  attr_accessor :excel, :path

  # 构造函数,如果未传path则是创建一个新的excel,   如果传了path,则打开这个excel,不过打开前会验证后缀与是否存在
  def initialize path = nil
    if path
      if path.match(/.xls$/)
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
  end

  # 打开一个excel
  def self.open path
    self.new path
  end

  # 获取一页
  def open_sheet name
    Ld::Sheet.open @excel, name
  end

  # 刷新 重读一次
  def flush
    @excel = Ld::Excel.open @path
  end

  # content_url = "Sheet1?b13:m27-g.j.k.(14:18)"
  def read address_path_full, simple = false, filter_nil = false
    raise "缺少?, 需要在'?'左边指定sheet的名称" if !address_path_full.match(/\?/)
    sheet_name, address_path = address_path_full.split('?')
    @current_sheet = open_sheet sheet_name
    arrs = @current_sheet.read address_path, simple
    # 除去不完整数据
    if filter_nil
      (arrs.size - 1).downto(0) do |i|
        arr = arrs[i]
        if arr[0] == nil or arr[1] == nil
          arrs.delete_at i
        end
      end
    end

    arrs
  end

  # 保存文件
  def save path
    puts "这个操作将会覆盖了这个文件:#{path}" if File.exist? path
    @excel.write path
    puts "保存excel成功:#{path}"
    self
  end

  def new_sheet name
    Ld::Sheet.new @excel, name
  end

  def write_sheet sheet_name, &block
    sheet = new_sheet sheet_name
    block.call sheet
    sheet.save
  end

  def self.create hash, &block
    excel = Ld::Excel.new
    block.call excel
    excel.save hash[:file_path]
  end

end

