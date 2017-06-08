class Ld::Routes

  attr_accessor :headings, :rows

  def initialize root, models
    @root = root
    @models = models
    parse
  end
  
  def parse
    system "rake routes > #{@root.path}/routes.txt" if !File.exist? "#{@root.path}/routes.txt"
    @rows = @root.find('routes.txt').lines.map{|line|
      arr = line.split(' ')
      arr.unshift(nil) if arr.size == 3
      arr
    }.delete_if{|arr| arr.size >= 5 or arr.size <= 2  }.map{|row|
      controller, action = row[3].split('#')
      controller_name = controller.split('/').last
      if @models
        @model_name = @models.models.include?(controller_name.singularize) ? controller_name.singularize : nil
      end
      type        = row[1]
      help_method = row[0]
      uri         = row[2]
      [@model_name,controller_name, action, type, uri, help_method]
    }.sort{|a,b| a[1] <=> b[1]}
    File.delete("#{@root.path}/routes.txt") if File.exist? "#{@root.path}/routes.txt"
    @headings = ['所属模型','控制器', 'action', '请求类型','URI','帮助方法']
  end
end