#require "protobuf"

module TestMessagesProto2

  struct Test4
    include Protobuf::Message

    contract do
      repeated :d, :int32, 4
    end
  end

  struct Test4Packed
    include Protobuf::Message

    contract do
      repeated :d, :int32, 4, packed: true
    end
  end

end
