require "../spec_helper"

describe Protobuf::Buffer do
  it "decodes a message correctly" do
    File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
      buf = Protobuf::Buffer.new(io)

      # f1: "dsfadsafsaf"
      buf.read_info.should eq({1, 2})
      buf.read_string.should eq("dsfadsafsaf")

      # f2: 234
      buf.read_info.should eq({2, 0})
      buf.read_int64.should eq(234)

      # fa: 2342134
      buf.read_info.should eq({3, 0})
      buf.read_uint64.should eq(2342134)

      # fa: 2342135
      buf.read_info.should eq({3, 0})
      buf.read_uint64.should eq(2342135)

      # fa: 2342136
      buf.read_info.should eq({3, 0})
      buf.read_uint64.should eq(2342136)

      # fb: -2342134
      buf.read_info.should eq({4, 0})
      buf.read_int32.should eq(-2342134)

      # fb: -2342135
      buf.read_info.should eq({4, 0})
      buf.read_int32.should eq(-2342135)

      # fb: -2342136
      buf.read_info.should eq({4, 0})
      buf.read_int32.should eq(-2342136)

      # fc
      buf.read_info.should eq({5, 2})
      tmp_buf = buf.new_from_length.not_nil!

      # fc: 4
      tmp_buf.read_int32.should eq(4)
      # fc: 7
      tmp_buf.read_int32.should eq(7)
      # fc: -12
      tmp_buf.read_int32.should eq(-12)
      # fc: 4
      tmp_buf.read_int32.should eq(4)
      # fc: 7
      tmp_buf.read_int32.should eq(7)
      # fc: -3
      tmp_buf.read_int32.should eq(-3)
      # fc: 4
      tmp_buf.read_int32.should eq(4)
      # fc: 7
      tmp_buf.read_int32.should eq(7)
      # fc: 0
      tmp_buf.read_int32.should eq(0)

      # pairs {
      #   key: "sdfff"
      #   value: "q\"qq\\q\n"
      # }

      buf.read_info.should eq({6, 2})
      buf.read_uint64 # read length

      buf.read_info.should eq({1, 2})
      buf.read_string.should eq("sdfff")

      buf.read_info.should eq({2, 2})
      buf.read_string.should eq("q\"qq\\q\n")

      # pairs {
      #   key: "   sdfff2  \321\202\320\265\321\201\321\202 "
      #   value: "q\tqq<>q2&\001\377"
      # }
      buf.read_info.should eq({6, 2})
      buf.read_uint64 # read length
      buf.read_info.should eq({1, 2})
      buf.read_string.should eq("   sdfff2  тест ")

      buf.read_info.should eq({2, 2})
      buf.read_string.should eq("q\tqq<>q2&\u{1}")

      # bbbb: "\000\001\002\377\376\375"
      buf.read_info.should eq({7, 2})
      buf.read_bytes.should eq(Slice[0u8, 1u8, 2u8, 255u8, 254u8, 253u8])

      # uint32: 4294967295
      buf.read_info.should eq({10, 0})
      buf.read_uint32.should eq(4294967295)
      # uint64: 18446744073709551615
      buf.read_info.should eq({11, 0})
      buf.read_uint64.should eq(18446744073709551615)
      # sint32: -2147483648
      buf.read_info.should eq({12, 0})
      buf.read_sint32.should eq(-2147483648)
      # sint64: -9223372036854775808
      buf.read_info.should eq({13, 0})
      buf.read_sint64.should eq(-9223372036854775808)
      # bool: 1
      buf.read_info.should eq({14, 0})
      buf.read_bool.should eq(true)
      # enum: 1
      buf.read_info.should eq({15, 0})
      buf.read_int32.should eq(1)
      # enum: 2
      buf.read_info.should eq({15, 0})
      buf.read_int32.should eq(2)
      # enum: 3
      buf.read_info.should eq({15, 0})
      buf.read_int32.should eq(3)
      # fixed64: 4294967296
      buf.read_info.should eq({16, 1})
      buf.read_fixed64.should eq(4294967296)
      # sfixed64: 2147483648
      buf.read_info.should eq({17, 1})
      buf.read_sfixed64.should eq(2147483648)
      # double: 20.64
      buf.read_info.should eq({18, 1})
      buf.read_double.should eq(20.64)
      # fixed32: 4294967295
      buf.read_info.should eq({19, 5})
      buf.read_fixed32.should eq(4294967295)
      # sfixed32: 2147483647
      buf.read_info.should eq({20, 5})
      buf.read_sfixed32.should eq(2147483647)
      # float: 20.32
      buf.read_info.should eq({21, 5})
      buf.read_float.should eq(20.32f32)

      # [gtt]: true
      buf.read_info.should eq({100, 0})
      buf.read_bool.should eq(true)

      # [gtg]: 20.0855369
      buf.read_info.should eq({101, 1})
      buf.read_double.should eq(20.0855369)
    end
  end
end
