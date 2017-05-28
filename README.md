# Ld

Practical small tools,
For the sake of efficiency,
The Module is my name abbreviations LD,
Basically has the following Class.

```ruby
module Ld
  class excel
  end
  class file
  end
  class table
  end
  class project
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

First ， into the console:

    $ rails c

Then, can do this:

```ruby
# Print model, Need to change the User model to exist, to run again
Ld::Table.p User.all, 'id , created_at'

# Create xls, Need to change the file path to your own, and then run
Ld::Excel.create '/Users/liudong/Desktop/excel_test.xls' do |excel|
  excel.write_sheet 'sheet1' do |sheet|
    sheet.set_format({color: :red, font_size: 11, font: '宋体'})
    sheet.set_headings ['title1','title2','title3']
    sheet.set_point 'a1'
    (1..10).to_a.each do |i|
      sheet.add_row i.times.map{|j| j}
    end
  end
end

# Read xls
Ld::Excel.open('/Users/liudong/Desktop/excel_test.xls').read('sheet1?a1:e10')

# Read Dir
Ld::File.open_dir('dir_path').children.each{|f| puts f.path}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ld. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

##