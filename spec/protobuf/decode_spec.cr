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

end
