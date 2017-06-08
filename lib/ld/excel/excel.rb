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

  def self.open path
    self.new path
  end

  def open_sheet name
    Ld::Sheet.open @excel, name
  end

  def flush
    @excel = Ld::Excel.open @path
  end

  # Example: address = "Sheet1?a1:f5"
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


  # 保存文件
  def save path
    puts "Covers a file: #{path}" if File.exist? path
    @excel.write path
    puts "Excel save success!"
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

