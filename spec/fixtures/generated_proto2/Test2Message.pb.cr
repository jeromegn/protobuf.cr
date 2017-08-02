#require "protobuf"

module TestMessagesProto2

  struct Test2
    include Protobuf::Message

    contract_of "proto2" do
      required :b, :string, 2
    end
  end
  end
