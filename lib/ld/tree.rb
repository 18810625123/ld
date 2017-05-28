class Ld::Tree
  attr_accessor :root_path, :root_name, :nodes, :depth, :id

  def initialize root_path
    @root_path = root_path
    @root_name = File.basename root_path
    @nodes = Ld::Nodes.new
    @numbers = 0
    @depth = 0
    @id = 0
  end

  def read_tree path = @root_path
    @depth+=1
    Dir.foreach(path)do |p|
      if !p.match(/^\./)
        node = Ld::Node.new(@id+=1, @depth, "#{path}/#{p}")
        @nodes << node
        if node.type == 1
          read_tree node.path
        end
      end
    end
  end

  def print_tree
    puts "#{@root_name}:"
    @nodes.sort_by_depth.each do |node|
      if node.type == 1
        print_tree
      else
        puts "\t"*node.id + "#{node.type}:#{node.name}"
      end
    end
  end



end
