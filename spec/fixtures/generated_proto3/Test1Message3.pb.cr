## Generated from Test1Message3.proto for com.acme.proto3
#require "protobuf"

module TestMessagesProto3

  struct Test1
    include Protobuf::Message

    contract do
      optional :a, :int32, 1
    end
  end

end
