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




## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ld. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

##
