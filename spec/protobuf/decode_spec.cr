require "../spec_helper"

require "../fixtures/test3.pb.cr"

# Proto3
describe "Protobuf::Message" do

  it "V3 int64 encode decode" do
    msg = TestMessagesV3::Test3.new
    msg.f2=131459961885904000_i64

    some_io = IO::Memory.new
    msg.to_protobuf some_io

    some_io.rewind

    msg2 = TestMessagesV3::Test3.from_protobuf some_io
    msg2.f2.should eq 131459961885904000_i64
  end

  it "V3 uint64 encode decode" do
    msg = TestMessagesV3::Test3.new
    msg.uint64=131459961885904000_u64

    some_io = IO::Memory.new
    msg.to_protobuf some_io

    some_io.rewind

    msg2 = TestMessagesV3::Test3.from_protobuf some_io
    msg2.uint64.should eq 131459961885904000_u64
  end

  it "V3 repeated non-scalar" do
    msg = TestMessagesV3::Test3.new

    pair1 = TestMessagesV3::Pair.new "key1", "val1"
    msg.pairs = [] of TestMessagesV3::Pair
    msg.pairs.not_nil!.push pair1

    some_io = IO::Memory.new
    msg.to_protobuf some_io

    some_io.rewind

    msg2 = TestMessagesV3::Test3.from_protobuf some_io
    pairs = msg2.pairs.not_nil!
    pairs.size.should eq 1
    pairs[0].key.should eq "key1"
    pairs[0].value.should eq "val1"
  end

end
