#require "protobuf"

module TestMessagesProto3

  struct TestOneof1
    include Protobuf::Message

    contract do
      optional :a, :int32, 1

      optional :oo0_a, :int32, 2, oneof_index: 0
      optional :oo0_b, :int32, 3, oneof_index: 0
      optional :oo0_c, :int32, 4, oneof_index: 0

      optional :b, :int32, 5

      optional :oo1_a, :int32, 6, oneof_index: 1
      optional :oo1_b, :int32, 7, oneof_index: 1
      optional :oo1_c, :int32, 8, oneof_index: 1

      oneof 0, "oo0"
      oneof 1, "oo1"
    end
  end
end
