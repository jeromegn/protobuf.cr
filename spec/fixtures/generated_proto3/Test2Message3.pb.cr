## Generated from Test2Message3.proto for com.acme.proto3
#require "protobuf"

module TestMessagesProto3

  struct Test2
    include Protobuf::Message

    contract_of "proto3" do
      optional :b, :string, 2
    end
  end
end
