# Ld

Practical small tools,
For the sake of efficiency,
The Module is my name abbreviations LD,
Basically has the following Class.


```ruby
module Ld
end
```
## Introduction to the

设计这个gem,我希望可以帮助大家在开发简单rails应用时,可以帮助大家完成50%以上的简单而重复的工作
我会提供一些类与方法,在console中使用,调用它们会生成项目结构xls文件,生成的这个xls文件中的数据,类似于一个小型文件数据库
然后我们可以以此为基础,查询项目中的一些信息.我想这样会有助于我们快速理解一个项目的基本结构,与重要文件在哪
也可以在修复bug时对bug相关文件与方法,起到快速定位的作用
这是我设计本gem的初衷,未来应该会持续更新这个gem,让它变得更加强大与方便
最终的目的是,希望这个gem可以起到快速搭建简单rails应用的作用,提升工作效率,节省时间
比如我们可以集成一些常用的模块到这个gem中,在搭建项目时只需要执行一条简单的命令就可以创建

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

First ， into the console:

    $ rails c

Then, can do this(进console后尝试以下方法):

```ruby
# Project details to /project.xls 查看项目详情,会生成xls文件,在: /project.xls
Ld::Project.new.to_xls

# Read xls
Ld::Excel.open('project.xls').read('models?a1:j100-f,h,i')
Ld::Excel.open('project.xls').read('tables?a1:i300')

# Create xls, Need to change the file path to your own, and then run
Ld::Excel.create :file_path =>'excel_test.xls' do |excel|
  excel.write_sheet 'sheet1' do |sheet|
    sheet.set_format({color: :red, font_size: 11, font: '宋体'})
    sheet.set_headings ['title1','title2','title3']
    sheet.set_point 'a1'
    sheet.set_rows [
      [1,2,3,4,5],
      [1,2,3,4],
      [1,2,3],
      [1,2],
      [1],
    ]
  end
end
Ld::Excel.open('excel_test.xls').read('sheet1?a1:g6')

# Print model, Need to change the User model to exist, to run again
Ld::Print.p User.first(10), 'id ,name, created_at'

# Read dir or file
Ld::File.new('Gemfile').lines.each{|l| puts l}
Ld::File.new('app').models.children.each{|f| puts f.name}
Ld::File.new('app').views.search_files(/.html/).each{|f| puts "#{f.father.name} : #{f.name}"}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ld. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

##
