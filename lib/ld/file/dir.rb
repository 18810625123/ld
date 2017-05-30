class Ld::Dir

  attr_accessor :path, :name, :dir, :dirs, :files

  def initialize path, dir = nil
    @path = path
    @dir = dir
    @name = File.basename path
    iter
  end

  # 迭代记录所有目录与文件
  def iter
    @dirs  = []
    @files = []
    Dir.foreach path do |p|
      if !['.','..','.DS_Store'].include?(p)
        if File.directory? "#{path}/#{p}"
          @dirs << Ld::Dir.new("#{path}/#{p}", self)
        else
          @files << Ld::File.new("#{path}/#{p}", self)
        end
      end
    end
  end

  # 手动
  def iter_all
    iter.dirs.each do |dir2|
      dir2.iter_all
    end
  end

  # 移动文件夹
  def mv_to dir
    files.each do |file|
      file.mv dir
    end
  end

  # 创建文件夹
  def mkdir name
    Dir.mkdir "#{path}/#{name}"
  end

  # 删除文件夹以及其下所有文件与目录
  def destroy_all
    # FileUtils.rm_r path
  end

  # 创建文件
  def create_file name
    File.new "#{@path}/#{name}"
  end

  # 创建文件夹
  def create_dir name
    Dir.mkdir "#{@path}/#{name}"
  end

  def print_tree
    dirs.each do |dir|
      puts "#{dir.name}"
    end
  end

  # 查看当前目录文件总大小
  def files_count
    sum = 0
    files.each do |file|
      sum += file.size
    end
    sum
  end

  # 查看当前目录下所有文件个数
  def sum_files_count count = 0
    @@sum_count = count + files.size
    # puts "#{@@sum_count}\t+=\t#{count}\t+\t#{files.size}"
    dirs.each do |dir|
      dir.sum_files_count @@sum_count
    end
    @@sum_count
  end

  # 查看当前目录下所有文件个数
  def sum_files_size size = 0
    @@sum_size = size + files_count
    # puts "#{@@sum_size}\t+=\t#{size}\t+\t#{files_count/1024.round(3)} (#{name})"
    dirs.each do |dir|
      dir.sum_files_size @@sum_size
    end
    @@sum_size
  end


  # 迭代打印当前目录下所有文件与文件夹的信息
  def info_all(i = 0)
    info(i)
    files_info(i)
    i += 1
    dirs.each_with_index do |dir,k|
      dir.info_all(i)
    end
    nil
  end

  # 打印当前目录下所有文件夹的信息
  def files_info(i = 0)
    files.each do |file|
      file.info(i + 1)
    end
    puts
  end

  # 打印当前目录的汇总信息
  def info(i = 0)
    print "\t" * i
    puts "目录#{path}下:子文件夹个数#{dirs.size},子文件个数#{files.size}"
    puts "总文件个数#{sum_files_count},当前文件夹大小#{files_count/1024.round(3)}K,文件夹总大小#{sum_files_size}K"
  end

end
