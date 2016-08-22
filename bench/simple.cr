require "../src/protobuf"

class MyMessage
  include Protobuf::Message
  contract do
    required :number, :int32,  1
    required :chars,  :string, 2
    required :raw,    :bytes,  3
    required :bool,   :bool,   4
    required :float,  :float,  5
  end
end

ITERS = 100_000


# benchmark message creation/encoding/decoding
#   rvm install 1.8.7 1.9.2 jruby rbx
#   rvm 1.8.7,1.9.2,jruby,rbx ruby bench/simple.rb

require "benchmark"

Benchmark.bm do |x|
  # x.report "object creation" do
  #   ITERS.times do
  #     Object.new
  #   end
  # end
  x.report "message creation" do
    ITERS.times do
      MyMessage.new(
        number: 12345,
        chars: "hello",
        raw: "world".to_slice,
        bool: true,
        float: 1.2345_f32
      )
    end
  end
  x.report "message encoding" do
    m = MyMessage.new(
      number: 12345,
      chars: "hello",
      raw: "world".to_slice,
      bool: true,
      float: 1.2345_f32
    )
    ITERS.times do
      m.to_protobuf
    end
  end
  x.report "message decoding" do
    io = MyMessage.new(
      number: 12345,
      chars: "hello",
      raw: "world".to_slice,
      bool: true,
      float: 1.2345_f32
    ).to_protobuf
    ITERS.times do
      MyMessage.from_protobuf(io.rewind)
    end
  end
end