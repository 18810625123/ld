class Ld::Dir

  attr_accessor :path, :name, :dirs, :files, :others, :all_files, :all_dirs, :all_others
  attr_accessor :all_others_sum, :all_files_sum

  def initialize path
    @path = path
    @name = @path.split('/').last
    @my = Ld::File.new @path
    get_all
  end

  def get_all
    @all = @my.search_regexp //, :all
    @all_files = []
    @all_dirs = []
    @all_others = []
    @all.each do |a|
      case a.type
        when 'directory'
          @all_dirs << a
        when 'file'
          @all_files << a
        else
          @all_others << a
      end
    end
    @all_files_sum  = (@all_files.map(&:size).sum.to_f / 1024 / 1024).round(1)
    @all_others_sum = (@all_others.map(&:size).sum.to_i / 1024).round(1)
    @all_suffix = {}
    @all_files.map(&:suffix).uniq.each do |suffix|
      @all_suffix[suffix] = get_suffix_count(suffix)
    end
    nil
  end

  def get_suffix_count suffix
    count = 0
    size = 0
    @all_files.each do |f|
      if f.suffix == suffix
        count += 1
        size += f.size
      end
    end
    return [count, (size.to_f / 1024).round(2)]
  end

  def details
    title = "目录名称:#{path.split('/').last}
    目录:#{@all_dirs.size}(个)
    文件:#{@all_files_sum}(Mb)/#{@all_files.size}(个)
    其它:#{@all_others_sum}(Kb)/#{@all_others.size}(个)"
    headings = ['文件类型(后缀)', '数量(个)', '大小(Kb)']
    rows = @all_suffix.map{|k,v| [k, v[0], v[1]]}.sort{|b,a| a[1] <=> b[1]}
    Ld::Print.print headings:headings,rows:rows,title:title
  end

  def search_all_suffix regexp
    @all_files.select{|f| f.suffix == regexp}
  end
end
