#require "protobuf"

module TestMessagesProto2

  struct Test3
    include Protobuf::Message

    contract do
      required :c, Test1, 3
    end
  end
  end
