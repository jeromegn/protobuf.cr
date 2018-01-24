struct Test
  include Protobuf::Message
  contract do
    required :f1, :string, 1
    required :f2, :int64, 2
    repeated :fa, :uint64, 3
    repeated :fb, :int32, 4
    repeated :fc, :int32, 5, packed: true
    repeated :pairs, Pair, 6
    optional :bbbb, :bytes, 7

    required :uint32, :uint32, 10
    required :uint64, :uint64, 11
    required :sint32, :sint32, 12
    required :sint64, :sint64, 13
    required :bool, :bool, 14

    repeated :enum, SomeEnum, 15

    required :fixed64, :fixed64, 16
    required :sfixed64, :sfixed64, 17
    required :double, :double, 18

    required :fixed32, :fixed32, 19
    required :sfixed32, :sfixed32, 20
    required :float, :float, 21

    optional :gtt, :bool, 100
    optional :gtg, :double, 101
  end
end

struct Pair
  include Protobuf::Message
  contract do
    required :key, :string, 1
    optional :value, :string, 2
  end
end

enum SomeEnum
  YES   = 1
  NO    = 2
  NEVER = 3
end

class EmptyMessage
  include Protobuf::Message

  contract do
  end
end

# extend Test {
#     optional bool gtt = 100;
#     optional double gtg = 101;
# }
