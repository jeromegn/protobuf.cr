require "../spec_helper"

# Encoding tests for simple examples on
# https://developers.google.com/protocol-buffers/docs/encoding

require "../fixtures/generated_proto3/*"
require "../fixtures/generated_proto2/*"

def msg_to_protobuf_hexstring(msg : Protobuf::Message)
  some_io = IO::Memory.new
  msg.to_protobuf some_io
  some_io.to_slice.hexstring
end

# Proto3
describe "Protobuf::Message" do
  it "V3 encodes varint Test1" do
    msg = TestMessagesProto3::Test1.new
    msg.a=150
    str = msg_to_protobuf_hexstring msg
    str.should eq "089601"
  end

  it "V3 encodes length-encoded string Test2" do
    msg = TestMessagesProto3::Test2.new
    msg.b = "testing"
    str = msg_to_protobuf_hexstring msg
    str.should eq "120774657374696e67"
  end

  it "V3 encodes included type Test3" do
    msg1 = TestMessagesProto3::Test1.new
    msg1.a=150
    msg = TestMessagesProto3::Test3.new
    msg.c=msg1
    str = msg_to_protobuf_hexstring msg
    str.should eq "1a03089601"
  end

  it "V3 encode Test3 with repeated non-scalar" do
    msg = TestMessagesV3::Test3.new

    # repeated non-scalar should not be packed

    pair1 = TestMessagesV3::Pair.new "key1", "val1"
    msg.pairs = [] of TestMessagesV3::Pair
    msg.pairs.not_nil!.push pair1

    str = msg_to_protobuf_hexstring msg
    # should not give type mismatch exception
    #str.should eq "320c0a046b657931120476616c31"
  end

  it "V3 encodes repeated (packed by default) Test4" do
    msg = TestMessagesProto3::Test4.new
    msg.d = [ 3,270, 86942]
    str = msg_to_protobuf_hexstring msg

    str.should eq "2206038e029ea705"
  end
end

# Proto2
describe "Protobuf::Message V2" do
  it "encodes varint Test1" do
    msg = TestMessagesProto2::Test1.new 150
    str = msg_to_protobuf_hexstring msg
    str.should eq "089601"
  end

  it "encodes length-encoded string Test2" do
    msg = TestMessagesProto2::Test2.new "testing"
    str = msg_to_protobuf_hexstring msg
    str.should eq "120774657374696e67"
  end

  it "encodes included type Test3" do
    msg1 = TestMessagesProto2::Test1.new 150
    msg = TestMessagesProto2::Test3.new msg1
    str = msg_to_protobuf_hexstring msg
    str.should eq "1a03089601"
  end

  it "encodes repeated Test4" do
    msg = TestMessagesProto2::Test4.new
    msg.d = [ 3,270, 86942]
    str = msg_to_protobuf_hexstring msg

    str.should eq "2003208e02209ea705" # unpacked
  end

  it "encodes repeated Test4 Packed" do
    msg = TestMessagesProto2::Test4Packed.new
    msg.d = [ 3,270, 86942]
    str = msg_to_protobuf_hexstring msg

    str.should eq "2206038e029ea705"  # packed
  end
end
