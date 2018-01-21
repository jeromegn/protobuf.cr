require "../spec_helper"

require "../fixtures/test.pb"

describe Protobuf::Message do
  it "decodes" do
    File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
      test = Test.from_protobuf(io)

      test.f1.should eq("dsfadsafsaf")
      test.f2.should eq(234)

      test.fa.should eq([2342134, 2342135, 2342136])

      test.fb.should eq([-2342134, -2342135, -2342136])

      test.fc.should eq [4,7,-12,4,7,-3,4,7,0]

      test.pairs.should eq([
        Pair.new(key: "sdfff", value: "q\"qq\\q\n"),
        Pair.new(key: "   sdfff2  тест ", value: "q\tqq<>q2&\u{1}")
      ])

      test.bbbb.should eq(Slice[0u8, 1u8, 2u8, 255u8, 254u8, 253u8])

      test.uint32.should eq(4294967295)
      test.uint64.should eq(18446744073709551615)
      test.sint32.should eq(-2147483648)
      test.sint64.should eq(-9223372036854775808)
      test.bool.should eq true

      test.enum.should eq [SomeEnum::YES, SomeEnum::NO, SomeEnum::NEVER]

      test.fixed64.should eq 4294967296
      test.sfixed64.should eq 2147483648

      test.double.should eq 20.64

      test.fixed32.should eq 4294967295
      test.sfixed32.should eq 2147483647

      test.float.should eq 20.32f32

      test.gtt.should eq true
      test.gtg.should eq 20.0855369
    end
  end

  it "encodes" do
    File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
      test = Test.from_protobuf(io)
      encoded = test.to_protobuf
      test2 = Test.from_protobuf(encoded.rewind)
      test.should eq(test2) # OMG
    end
  end

  it "encodes empty-list as repeated" do
    test4 = TestMessagesProto2::Test4.new(d: [] of Int32)
    test4.to_protobuf.empty?.should be_true
  end
end
