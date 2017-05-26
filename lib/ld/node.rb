class Ld::Node
  attr_accessor :id, :depth, :name, :path ,:type, :suffix

  def initialize id, depth, path
    @id    = id
    @depth = depth
    @path  = path
    @type  = File.directory?(path) ? 1 : 0
    @name  = File.basename path
    @suffix = @type == 1 ? nil : @name.split('.').last
  end

end