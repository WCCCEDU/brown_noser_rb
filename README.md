# BrownNoser

This tool is to help manage and inspect Git Repos used for our the Coursework at WCCCEDU.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brown_noser', '~> 0.1.2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brown_noser

## Usage

This gem exposes the `pet` command

### Sync PR Branches
Bring unmerged branches to local repo for easy viewing and searching without merging.
```
pet <user> <repo> -u <username> -p <password> -s
pet <user> <repo> --username <username> --pasword <password> --sync
```

### Search for patterns in local repo (Help find cheating)
```
pet -f 'Your query or Regex'
pet --find 'Your query or Regex'
```

## Development

Clone and run `bundle install` to receive deps.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WCCCEDU/brown_noser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

