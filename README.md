# Ruboty::Fastly

## Installation

```ruby
gem 'ruboty-fastly'
```

Then set an API key to `$FASTLY_API_KEY`.

## Usage


```
> ruboty fst list
- `SERVICE_ID` NAME

> ruboty fst purge http://...
Purged http://...

> ruboty fst purge key SERVICE_ID KEY1 KEY2...
Purged Fastly SERVICE_ID by key: `KEY1`
Purged Fastly SERVICE_ID by key: `KEY2`

> ruboty fst purge all SERVICE_ID
Purging Fastly `SERVICE_ID` after next 15 seconds, cancel by saying: `fastly cancel`
Purged all from Fastly `SERVICE_ID`

> ruboty fst cancel
Cancelled the pending purge requests.

> ruboty fst add alias SERVICE_ID NAME
> ruboty fst remove alias NAME
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/ruboty-fastly.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
