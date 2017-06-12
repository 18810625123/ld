class Ld::File

  attr_accessor :path, :name, :exist, :size, :mode, :type, :stat
  @@current_path = Dir.pwd
  @@exclude = ['.', '..']

  def initialize path
    @path = path[0] == '/' ? path : "#{Dir.pwd}/#{path}"
    @name = File.basename @path
    if File.exist? @path
      @exist = true
      @type = File.ftype path
      @stat = File.stat path
      @size = @stat.size
      @mode = @stat.mode
    else
      @exist = false
      @type = 'not found'
    end
  end

  #= 作用 打开一个文件
  def self.open path
    self.new path
  end

  #= 作用 返回这个目录下的所有一级目录与一级文件,如果不是目录,会报错
  def children
    dir!
    Dir.foreach(@path).map{|n| Ld::File.new("#{@path}/#{n}") if !is_exclude? n}.compact.sort{|a,b| a.type <=> b.type}
  end

  def is_exclude? name
    @@exclude.include? name
  end

  #= 作用 返回当前所在目录(Dir.pwd)
  def self.current
    Ld::File.new @@current_path
  end

  def exist!
    raise "不存在的 #{path}" if !@exist
  end

  #= 作用 判断这是目录吗
  def dir?
    type == 'directory'
  end

  #= 作用 判断这是文件吗
  def file?
    type == 'file'
  end

  def dir!
    raise "这不是一个目录,而是一个#{type}:#{path}" if type != 'directory'
  end

  def file!
    raise "这不是一个文件,而是一个#{type}:#{path}" if type != 'file'
  end

  #= 作用 查找文件或目录,返回一个一级目录或文件,如果不存在则返回nil
  def find name
    dir!
    Ld::File.new "#{path}/#{name.to_s}" if File.exist? "#{path}/#{name.to_s}"
  end

  #= 作用 精确查找,返回所有匹配的目录和文件
  def search name, type = :all
    dir!
    results = []
    iter_search name, results
    case type.to_s
      when 'all'
        results
      when 'file'
        results.map{|f| f.type == 'file'}
      when 'dir'
        results.map{|f| f.type == 'directory'}
    end
  end

  #= 作用 模糊查找,返回所有匹配的目录和文件
  def search_regexp regexp, type = :all
    dir!
    results = []
    iter_search_regexp regexp, results
    case type.to_s
      when 'all'
        results
      when 'file'
        results.map{|f| f.type == 'file'}
      when 'dir'
        results.map{|f| f.type == 'directory'}
    end
  end

  def iter_search name, results
    children.each do |file|
      if file.name == name
        results << file
      end
      if file.dir?
        file.iter_search name, results
      end
    end
  end

  def iter_search_regexp regexp, results
    children.each do |file|
      if file.name.match(regexp)
        results << file
      end
      if file.dir?
        file.iter_search_regexp regexp, results
      end
    end
  end

  #= 作用 如果是一个文本文件,返回所有行
  def lines
    File.open(@path).readlines
  end

  # def method_missing name
  #   find name
  # end

  #= 作用 修改名称(目录或文件均可)
  def rename new_name
    new_path = "#{dir.path}/#{new_name}"
    if File.rename @path, new_path
      @path = new_path
    end
  end

  #= 作用 删除当前文件(有gets确认)
  def delete
    puts "删除!:#{path}\n,确认请输入 delete_file,"
    if gets.chomp == 'delete_file'
      if File.delete path == 1
        @exist = false
        puts "删除成功 #{path}"
      end
    end
  end

  #= 作用 返回所有文件
  def files
    children.select{|f| f.type == 'file'}
  end

  #= 作用 返回父目录
  def parent
    Ld::File.new(File.dirname @path)
  end

  #= 作用 返回所有兄弟
  def siblings
    parent.children
  end

  #= 作用 返回所有目录
  def dirs
    children.select{|f| f.type == 'directory'}
  end

  #= 作用 输出目录中所有条目
  def ls
    if type == 'directory'
      Ld::Print.ls self
    elsif type == 'file'
      Ld::Print.ls self.parent
    end
  end

  def self.write path, arr
    File.open(path)
  end

  # test:
  def self.test
    sdf{100.times{Ld::File.new('app').search_regexp //}}
  end

  def sdf &block
    t1 = Time.new
    block.call
    t2 = Time.new
    puts t2 - t1
  end

end
