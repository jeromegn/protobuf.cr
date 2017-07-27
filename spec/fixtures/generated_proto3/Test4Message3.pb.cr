## Generated from Test4Message3.proto for com.acme.proto3
#require "protobuf"

module TestMessagesProto3

  struct Test4
    include Protobuf::Message

    contract_of "proto3" do
      repeated :d, :int32, 4
    end
  end

end
