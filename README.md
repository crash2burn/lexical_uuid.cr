# lexical_uuid.cr

This is a port of ruby's LexicalUUID. It provides a way to go to and from ORDERED v1 UUIDS.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  lexical_uuid.cr:
    github: crash2burn/lexical_uuid.cr
```

## Usage

```crystal
require "lexical_uuid.cr"

uuid = LexicalUUID::UUID.new
puts uuid.to_guid #=> "00056e19-aa1e-2c81-33b7-7ccf993414bd"

from_bytes = LexicalUUID::UUID.new(uuid.to_bytes)
puts from_bytes.to_guid #=> "00056e19-aa1e-2c81-33b7-7ccf993414bd"

from_guid = LexicalUUID::UUID.new(uuid.to_guid)
puts from_guid.to_guid #=> "00056e19-aa1e-2c81-33b7-7ccf993414bd"
```


## Contributing

1. Fork it ( https://github.com/crash2burn/lexical_uuid.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [crash2burn](https://github.com/crash2burn) crash2burn - creator, maintainer
