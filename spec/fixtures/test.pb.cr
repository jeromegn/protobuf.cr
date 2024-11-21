## Generated from test.proto
# require "protobuf"

enum SomeEnum
  YES = 0
  NO = 1
  NEVER = 2
  OTHER_VALUE = 3
  SOMEENUMOTHERVALUE = 3
end

struct Test
  include ::Protobuf::Message
  
  contract_of "proto2" do
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
    repeated :ss, :string, 22
    repeated :bb, :bytes, 23
  end
end

struct Pair
  include ::Protobuf::Message
  
  contract_of "proto2" do
    required :key, :string, 1
    optional :value, :string, 2
  end
end

struct EmptyMessage
  include ::Protobuf::Message
  
  contract_of "proto2" do
  end
end
