#require "protobuf"

module TestMessagesProto2

  struct Test2
    include Protobuf::Message

    contract do
      required :b, :string, 2
    end
  end
  end
