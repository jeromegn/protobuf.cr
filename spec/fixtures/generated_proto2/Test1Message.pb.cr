#require "protobuf"

module TestMessagesProto2

  struct Test1
    include Protobuf::Message

    contract do
      required :a, :int32, 1
    end
  end

end
