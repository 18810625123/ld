# Ld

Practical small tools,
For the sake of efficiency,
The Module is my name abbreviations LD,
Basically has the following Class.


```ruby
module Ld
  class File
  end
  class Excel
  end
  class Project
  end
  class Print
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ld'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ld

## Usage

1. Ld::Excel
```ruby
# write excel
Ld::Excel.create :file_path => 'config/excel_test.xls' do |excel|
  excel.write_sheet 'abc' do |sheet|
    sheet.set_format({color: :red, font_size: 20, font: '微软雅黑'})
    sheet.set_point 'a1'
    sheet.set_headings ['A','B','C','D']
    sheet.set_rows([
      ['1','2','3','4'],
      ['2','3','4','5'],
      ['3','4','5','6'],
      ['4','5','6','7']
    ])
  end
end

# read excel
excel = Ld::Excel.open('config/excel_test.xls')
excel.read('abc?a1:b5')
excel.read({sheet: 'abc', scope:'a1:b5'})
excel.read({sheet: 'abc', scope:'a1:b5', exclude:'3'})
excel.read({sheet: 'abc', scope:'a1:b5', exclude:'B'})
```


2. Ld::Project
```ruby
# Check the project details
project = Ld::Project.new(Rails.root.to_s)

# create excel to 'config/project_details.xls'

# Check model infos
project.to_xls('config/project_details.xls')
project.print :user, :fields
project.print :user, :relations
project.print :user, :routes
project.print :user, :controllers
project.print :user, :views

```


3. Ld::File
```ruby
# read file all lines
file = Ld::File.open('config/application.rb')
lines = file.lines

# read dir
dir = Ld::File.open('app/models')
files = dir.children

# search dir file by file name
files = dir.search_files(/.rb$/)

# Ld::File API
Ld::File.open path
Ld::File.new path
file.children
file.brothers
file.father
file.lines
file.search_files(//)
file.search_dirs(//)
file.name
file.path
file.type  # 0=file, 1=dir
```


4. Ld::Print
```ruby
users = User.first(10)
Ld::Print.p users, 'id ,name, created_at'
```


## API

### Ld::Project
* `initialize table_hash = {}, project_root_path = Rails.root.to_s`
 * 作用:解析一个项目的代码获得结构化的数据

* `print model_name, type = :relations`
 * 作用:查看模型的相关信息(参数有:relations,fields,tables,routes,views,controllers)

* `to_xls path = {:file_path => "#{@root.path}/project.xls"}`
 * 作用:将这个项目的代码分析结果保存到excel文件(默认在项目根目录下的project.xls)

### Ld::Document
* `initialize file`
 * 作用:读一个rb文件生成api数据

### Ld::Excel
* `self.open path`
 * 作用:打开一个xls文件,返回Ld::Excel实例

* `self.write path, &block`
 * 作用:写excel(创建新的xls文件)

* `self.create path, &block`
 * 作用:write的同名方法

* `read params, show_location = false`
 * 示例:Ld::Excel.read "Sheet1?A1:B2"
 * 作用:读xls文件中的内容,二维数组

* `read_with_location params`
 * 作用:与read方法相同(但会多返回坐标数据)

### Ld::Sheet
* `set_headings headings`
 * 作用:在当前sheet的主体内容顶上方添加一个表头(传入二维数组),但不写入(只有调用Ld::Excel的实例方法save才会写入io)

* `set_color color`
 * 作用:设置当前sheet页的字体颜色

* `set_font_size size`
 * 作用:设置当前sheet页的字体大小

* `set_font font`
 * 作用:设置当前sheet页的字体

* `set_weight weight`
 * 作用:设置当前sheet页的单元格宽度(暂时无效)

* `set_point point`
 * 作用:设置当前sheet页的字体颜色

### Ld::File
* `self.open path`
 * 作用:打开一个文件

* `children `
 * 作用:返回这个目录下的所有一级目录与一级文件,如果不是目录,会报错

* `self.current `
 * 作用:返回当前所在目录(Dir.pwd)

* `dir? `
 * 作用:判断这是目录吗

* `file? `
 * 作用:判断这是文件吗

* `find name`
 * 作用:查找文件或目录,返回一个一级目录或文件,如果不存在则返回nil

* `search name, type = :all`
 * 作用:精确查找,返回所有匹配的目录和文件

* `search_regexp regexp, type = :all`
 * 作用:模糊查找,返回所有匹配的目录和文件

* `lines `
 * 作用:如果是一个文本文件,返回所有行

* `rename new_name`
 * 作用:修改名称(目录或文件均可)

* `delete `
 * 作用:删除当前文件(有gets确认)

* `files `
 * 作用:返回所有文件

* `parent `
 * 作用:返回父目录

* `siblings `
 * 作用:返回所有兄弟

* `dirs `
 * 作用:返回所有目录

* `ls `
 * 作用:输出目录中所有条目

### Ld::Print
* `self.p models, fields`
 * 作用:格式化打印模型数组




## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ld. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

##
