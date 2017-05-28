# Ld

提供开发基础功能,旨在提高日常工作的开发效率
主要有以下类:
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

```ruby
    Ld::Table.p User.all, 'id ,name , created_at'
    Ld::Excel.open('/Users/liudong/Desktop/abss.xls').read('sh1?a1:c5')
    Ld::Excel.create '/Users/liudong/Desktop/abss.xls' do |excel|
      ['sh1','sh2','发有3'].each do |sheet_name|
        excel.write_sheet sheet_name do |sheet|
          sheet.set_format({color: :red, font_size: 22, font: '宋体'})
          sheet.set_headings ['a','b']
          sheet.set_point 'c5'
          (5..22).to_a.each do |i|
            sheet.add_row i.times.map{|j| '村腰里 是'}
          end
        end
      end
    end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ld. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

##