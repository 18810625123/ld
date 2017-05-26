class Ld::File

  attr_accessor :path, :name, :type

  def initialize path
    @path = path
    @name = File.basename @path
    @type = File.directory?(@path) ? 1 : 0
  end

  def brothers
    father.children
  end

  def children
    arr = []
    Dir.foreach(@path)do |p|
      if !['.','..','.DS_Store'].include?(p)
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

  def method_missing name
    find name
  end

end
