class Ld::Project

  attr_accessor :root, :app, :name, :path, :models, :views_dir, :views, :controllers, :routes

  def initialize path
    @root = Ld::File.new(path)
    @app = @root.app
    @models = @app.models.search(/.rb$/)
    @views_dir = @app.views.children
    @views = @app.views.search(/.html/)
    @controllers = @app.controllers.search(/_controller.rb$/)
    @routes = @root.config.find('routes.rb')
  end

  def self.p model = :all
    @@p ||= Ld::Project.new(Rails.root.to_s)

    t = Terminal::Table.new
    case model.to_s
      when 'all'
        t.title = "project:#{@@p.root.name}"
        t.headings = ['models', 'views', 'controllers', 'routes']
        t.add_row [@@p.models.size, @@p.views.size, @@p.controllers.size, @@p.routes.lines.size]
      when 'models'
        t.title = 'models'
        t.headings = ['name', 'action-size', 'line-size', 'routes']
        @@p.models.map{|f| [f.name.split('.')[0], f.lines.map{|l| l if l.match(/def /)}.compact.size, f.lines.size, nil] }
            .sort{|a,b| b[1]-a[1]}.each{|i| t.add_row i}
      when 'controllers'
        t.title = 'controllers'
        t.headings = ['name', 'action-size', 'line-size']
        @@p.controllers.map{|f| [f.name.split('.')[0], f.lines.map{|l| l if l.match(/def /)}.compact.size, f.lines.size] }
            .sort{|a,b| b[1]-a[1]}.each{|i| t.add_row i}
      when 'views'
        t.title = 'views'
        t.headings = ['name', 'file-size', 'html']
        @@p.app.views.children('shared')
            .map{|f| htmls = f.search(/.html/);[f.name, htmls.size, htmls.map{|f2| f2.name.split('.')[0]}.join(' ')]}
            .sort{|a,b| b[1]-a[1]}
            .each{|arr| t.add_row arr}
      when 'routes'
        file = Ld::File.new @@p.root.path + '/routes.txt'
        if !file.exist?
          system "rake routes > #{@@p.root.path + '/routes.txt'}"
        end
        arrs = file.lines.map{|l| lines = l.split(' '); lines.size == 3 ? lines.unshift(nil) : lines}
        arrs.delete_at 0
        t.title = 'routes'
        t.headings = ['controller', 'action', 'type']
        arrs.map{|arr| controller,action = arr[3].split('#'); [controller, action, arr[1]]}
            .each{|arr| t.add_row arr}
      else
        puts '(models/controllers/views)'
        return
    end
    puts t
  end

end