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

  it "handles oneof in proto2" do
    # When multiple oneof values are populated
    # by the ctor only the first survives
    msg = TestMessagesProto2::TestOneof1.new(
      a: 1,
      oo0_a: 2, oo0_b: 3, oo0_c: 4,
      b: 5,
      oo1_a: 6, oo1_b: 7, oo1_c: 8
    )

    payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
    payload.should eq([1, 2, nil, nil, 5, 6, nil, nil])

    # `msg.foo` tells us the string name
    # of the member `foo` that is set
    msg.oo0.should eq("oo0_a")
    msg.oo1.should eq("oo1_a")

    # Setting values outside of oneof's leaves the oneof's untouched
    msg.a = 1
    msg.b = 5
    payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
    payload.should eq([1, 2, nil, nil, 5, 6, nil, nil])

    # Setting a oneof value resets the others in the same oneof
    msg.oo0_b = 3
    payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
    payload.should eq([1, nil, 3, nil, 5, 6, nil, nil])
    msg.oo0.should eq("oo0_b")

    msg.oo1_b = 7
    payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
    payload.should eq([1, nil, 3, nil, 5, nil, 7, nil])
    msg.oo0.should eq("oo0_b")
    msg.oo1.should eq("oo1_b")
  end

  it "handles oneof in proto2 and proto3" do
    [TestMessagesProto2::TestOneof1, TestMessagesProto3::TestOneof1].each do |message_class|
      # When multiple oneof values are populated
      # by the ctor only the first survives
      msg = message_class.new(
        a: 1,
        oo0_a: 2, oo0_b: 3, oo0_c: 4,
        b: 5,
        oo1_a: 6, oo1_b: 7, oo1_c: 8
      )

      payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
      payload.should eq([1, 2, nil, nil, 5, 6, nil, nil])

      # `msg.foo` tells us the string name
      # of the member `foo` that is set
      msg.oo0.should eq("oo0_a")
      msg.oo1.should eq("oo1_a")

      # Setting values outside of oneof's leaves the oneof's untouched
      msg.a = 1
      msg.b = 5
      payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
      payload.should eq([1, 2, nil, nil, 5, 6, nil, nil])

      # Setting a oneof value resets the others in the same oneof
      msg.oo0_b = 3
      payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
      payload.should eq([1, nil, 3, nil, 5, 6, nil, nil])
      msg.oo0.should eq("oo0_b")

      msg.oo1_b = 7
      payload = [ msg.a, msg.oo0_a, msg.oo0_b, msg.oo0_c, msg.b, msg.oo1_a, msg.oo1_b, msg.oo1_c ]
      payload.should eq([1, nil, 3, nil, 5, nil, 7, nil])
      msg.oo0.should eq("oo0_b")
      msg.oo1.should eq("oo1_b")

      # Serialization and deserialization through protobuf
      deser_msg = msg.class.from_protobuf(msg.to_protobuf)
      msg.should eq(deser_msg)

      deser_msg.a.should eq(1)
      deser_msg.oo0_a.should eq(nil)
      deser_msg.oo0_b.should eq(3)
      deser_msg.oo0_c.should eq(nil)

      deser_msg.oo1_a.should eq(nil)
      deser_msg.oo1_b.should eq(7)
      deser_msg.oo1_c.should eq(nil)

      deser_msg.oo0.should eq("oo0_b")
      deser_msg.oo1.should eq("oo1_b")
    end
  end
end
