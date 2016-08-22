# Benchmarks

Compared to [beefcake](https://github.com/protobuf-ruby/beefcake), for 100 000 iterations.

### Beefcake ([source](https://github.com/protobuf-ruby/beefcake/blob/86e750e556eee930e089c4a5238db6b9b605681b/bench/simple.rb))

Rehearsed (via Ruby's `Benchmark.bmbm` method):

```
ruby bench/simple.rb

                       user     system      total        real
message creation   0.580000   0.010000   0.590000 (  0.597887)
message encoding   2.130000   0.010000   2.140000 (  2.152908)
message decoding   2.940000   0.010000   2.950000 (  3.006080)
```

### protobuf.cr ([source](https://github.com/jeromegn/protobuf.cr/blob/9365277142360686141835b86afa24949e527d20/bench/simple.cr))

```
crystal run --release bench/simple.cr

                       user     system      total        real
message creation   0.000000   0.000000   0.000000 (  0.005799)
message encoding   0.070000   0.020000   0.090000 (  0.086418)
message decoding   0.050000   0.010000   0.060000 (  0.051049)
```