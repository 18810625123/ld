class Ld::Routes

  attr_accessor :headings, :rows

  def initialize project
    @project = project
    root = @project.root
    system "rake routes > #{root.path}/routes.txt"
    rows = root.find('routes.txt').lines.map{|line|
      arr = line.split(' ')
      arr.unshift(nil) if arr.size == 3
      arr
    }
               .delete_if{|arr| arr.size >= 5 or arr.size <= 2  }
               .map{|row|
      controller, action = row[3].split('#')
      type        = row[1]
      help_method = row[0]
      uri         = row[2]
      #
      [controller, action, type, uri, help_method]
    }
    File.delete("#{root.path}/routes.txt") if File.exist? "#{root.path}/routes.txt"
    @headings = ['控制器', 'action', '请求类型','URI','帮助方法']
    @rows = rows
  end
  
  
end