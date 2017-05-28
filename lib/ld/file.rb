class Ld::File

  attr_accessor :path, :base_name, :name, :type

  def initialize path
    @path = path
    @name = File.basename @path
    @base_name = name.split('.')[0]
    @type = File.directory?(@path) ? 1 : 0
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

  def where regexp
    arr = []
    iter_search regexp, arr
    arr
  end

  def search regexp
    arr = []
    iter_search regexp, arr
    arr
  end

  def iter_search regexp, arr
    children.each do |f|
      if f.type == 1
        f.iter_search regexp, arr
      end
      if f.name.match(regexp)
        arr << f
      end
    end
    self
  end

  def iter arr
    children.each do |f|
      if f.type == 1
        f.iter arr
      end
      arr << f
    end
    self
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
