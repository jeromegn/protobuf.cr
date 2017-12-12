# protobuf [![Build Status](https://travis-ci.org/jeromegn/protobuf.cr.svg?branch=master)](https://travis-ci.org/jeromegn/protobuf.cr) [![Dependency Status](https://shards.rocks/badge/github/jeromegn/protobuf.cr/status.svg)](https://shards.rocks/github/jeromegn/protobuf.cr) [![devDependency Status](https://shards.rocks/badge/github/jeromegn/protobuf.cr/dev_status.svg)](https://shards.rocks/github/jeromegn/protobuf.cr)

Crystal shard to decode, encode and generate protobuf messages.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  protobuf:
    github: jeromegn/protobuf.cr
```

### Install protobuf

macOS:
```brew install protobuf```

Ubuntu
```sudo apt-get install -y protobuf-compiler```

## Versioning

This library does not follow semver conventions for versioning. It started off at v2.0.0 because it supports protobuf v2. From there, it'll increment versions based on semver, except for breaking changes, where I will not increment the major version.

## Usage

### Decoding and encoding messages

`to_protobuf(io : IO)` and `from_protobuf(io : IO)` are available on enums and anything that includes `Protobuf::Message` and defines a `contract`

Example:

```crystal
require "protobuf"

enum Foo
  FOO
end

struct MyMessage
  include Protobuf::Message
  contract do
    # some required properties
    required :prop_name, :int32, 1, default: 123
    required :prop2, Foo, 2

    # optional properties
    optional :optional_prop_name, :string, 3

    # repeated fields
    repeated :my_array, :int32, 4 # produces a property of type Array(Int32)?
  end

  # write your methods like you normally would here, if you like.
end

proto_io = File.read("path/to/encoded/protobuf") # get your IO in some way

msg = MyMessage.from_protobuf(proto_io) # returns a an instance of MyMessage
                                  # from a valid protobuf encoded message

msg.to_protobuf # return a IO::Memory filled with the encoded message

some_io = IO::Memory.new
msg.to_protobuf(some_io) # fills up the provided IO with the encoded message
```

#### Field types

All field types supported by the protobuf protocol v2 are available as symbols or the name of a Crysta; struct or class.

#### Constructor

Using the `contract` block creates an initializer with all the properties defined in it. It also creates an initializer which can consume a `Protobuf::Buffer` (used by `from_protobuf` method), not unlike `JSON::PullParser`.

### Generating Crystal protobuf messages

Protobuf provides the `protoc` executable to encode, decode and **generate** language-specific protobuf messages via plugins.

#### 1. Install the protoc plugin

##### macOS:

```
brew install jeromegn/tap/protoc-gen-crystal
```

##### Ubuntu:

```
crystal build bin/protoc-gen-crystal.cr -o ~/bin/protoc-gen-crystal
```

#### 2. Generate `.pb.cr` files

```bash
protoc -I <.protos_basepath> --crystal_out <path_to_folder_for_protobufs> <path_to_{.proto,*.protos}>
```

#### Generator options

The generator is configurable via environment variables:

- `PROTOBUF_NS` - If your want to namespace everything under a module (default: `""`). Please write with a CamelCase format (ie: `"MesosMessage"` would produce `module MesosMessage`)
- `STRIP_FROM_PACKAGE` - Protobuf has package namespaces and sometimes messages reference other namespaces (ie: `mesos.v1.scheduler.Call`), but you want those to be namespaced in a Crystal-like fashion (ie: `Scheduler::Call`), then you can specify a string to strip from the packages for each file (ie: `STRIP_FROM_PACKAGE=mesos.v1`) and the rest will be CamelCased

## Known Limitations

- Does not support non-UTF8 strings...

## Development

To generate encoded protobufs, you can create a `.proto` and a "raw" data protobuf file and use `protoc` to encode the data.

For example:

```
cat spec/fixtures/test.data | protoc -I spec/fixtures --encode=Test spec/fixtures/test.proto > spec/fixtures/test.data.encoded
```

## Contributing

1. Fork it ( https://github.com/jeromegn/protobuf.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jeromegn](https://github.com/jeromegn) Jerome Gravel-Niquet - creator, maintainer
