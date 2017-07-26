## Generated from Test3Message3.proto for com.acme.proto3
#require "protobuf"

module TestMessagesProto3

  struct Test3
    include Protobuf::Message

    contract do
      optional :c, Test1, 3
    end
  end
end
