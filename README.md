# protobuf [![Build Status](https://travis-ci.org/jeromegn/protobuf.cr.svg?branch=master)](https://travis-ci.org/jeromegn/protobuf.cr) [![Dependency Status](https://shards.rocks/badge/github/jeromegn/protobuf.cr/status.svg)](https://shards.rocks/github/jeromegn/protobuf.cr) [![devDependency Status](https://shards.rocks/badge/github/jeromegn/protobuf.cr/dev_status.svg)](https://shards.rocks/github/jeromegn/protobuf.cr)

TODO: Write a description here

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
```sudo apt-get install -y protobuf```

## Generating Crystal protobuf messages

Protobuf provides the `protoc` executable to encode, decode and **generate** language-specific protobuf messages via plugins.

`shards` don't yet support shipping binaries, so you'll have to clone and generate yours by yourself.

### 1. Generate the plugin binary

```
git clone https://github.com/jeromegn/protobuf.cr
crystal build protobuf.cr/bin/protoc-gen-crystal.cr -o /usr/local/bin/protoc-gen-crystal # or anywhere in your PATH
```

### 2. Generate `.pb.cr` files

```bash
protoc -I <.protos_basepath> --crystal_out <path_to_folder_for_protobufs> <path_to_{.proto,*.protos}>
```

### Generator options

The generator is configurable via environment variables:

- `PROTOBUF_NS` - If your want to namespace everything under a module (default: `""`). Please write with a CamelCase format (ie: `"MesosMessage"` would produce `module MesosMessage`)
- `STRIP_FROM_PACKAGE` - Protobuf has package namespaces and sometimes messages reference other namespaces (ie: `mesos.v1.scheduler.Call`), but you want those to be namespaced in a Crystal-like fashion (ie: `Scheduler::Call`), then you can specify a string to strip from the packages for each file (ie: `STRIP_FROM_PACKAGE=mesos.v1`) and the rest will be CamelCased

## Known Limitations

- Does not support ASCII strings...

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
