class Ld::Nodes
  attr_accessor :nodes

  def initialize nodes = []
    @nodes = nodes
  end

  def << node
    @nodes << node
  end

  def where option
    sql = ""
    if option.instance_of?(String)
      sql = option
    elsif option.instance_of?(Hash)
      sql = option.map{|k,v| "node.#{k} == #{v.instance_of?(String) ? "'#{v}'" : "#{v}"}"}.join(" and ")
    end
    @nodes.map{|node| if(eval(sql));node;end}.compact
  end

  def find id
    @nodes.each{|node| return node if node.id == id}
  end

  def size
    @nodes.size
  end

  def sort_by_depth
    @nodes.sort{|a,b| a.depth - b.depth}
  end
end