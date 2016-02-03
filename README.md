# BrownNoser

This tool is to help manage and inspect Git Repos used for our the Coursework at WCCCEDU.

## Major Milestones
- Sync pull request branches locally so they can be reviewed and graded locally
- Search all submissions to validate academnic honesty
- Step through each submission branch and build/compile/execute the code
- Run automated tests and fuzzy acceptance on output on each submission based on a project described _Rubric_ file
- Provide DSL to work with compiled and web based execution
- Integrate with Linters to verify student style to save time on pedantic comments by automating comments on student repos for teachers review.

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

