class Ld::File

  attr_accessor :path, :base_name, :name, :type

  def initialize path
    # raise "file is not found!\n#{path}" if !File.exist? path
    @path = path
    @name = File.basename @path
    @base_name = name.split('.')[0]
    @type = File.directory?(@path) ? 1 : 0
  end

  def self.open_dir path
    Ld::File.new path
  end

  def self.open path
    if File.exist? path
      self.new path
    else
      return nil
    end
  end

  def brothers
    father.children
  end

  def children(remove = nil)
    arr = []
    Dir.foreach(@path)do |p|
      removes = ['.','..','.DS_Store']
      removes << remove if remove
      if !removes.include?(p)
        arr << Ld::File.new("#{@path}/#{p}")
      end
    end
    arr.sort!{|a,b| b.type-a.type}
    arr
  end

  def search_files regexp
    arr = []
    iter_search_files regexp, arr
    arr
  end

  def search_dirs
    arr = []
    iter_search_dir arr
    arr
  end

  def iter_search_dir arr
    children.each do |f|
      if f.type == 1
        arr << f
        f.iter_search_dir arr
      end
    end
    self
  end

  def iter_search_files regexp, arr
    children.each do |f|
      if f.type == 1
        f.iter_search_files regexp, arr
      end
      if f.name.match(regexp)
        arr << f
      end
    end
    self
  end

  def father
    arr = @path.split('/')
    arr.pop
    Ld::File.new(arr.join('/'))
  end

  def find name
    name = name.to_s
    children.each do |f|
      if f.name == name
        return f
      end
    end
    return nil
  end

  def read
    File.open(@path).read
  end

  def readlines
    File.open(@path).readlines
  end

  def size
    File.size path
  end

  def lines
    arr = []
    File.new(path).each_line{|l| arr << l }
    arr
  end

  def exist?
    File.exist? path
  end

  def method_missing name
    find name
  end

end
