require "./enum"

module Protobuf
  PB_TYPE_MAP = {
    # wire type 0
    :int32  => Int32,
    :int64  => Int64,
    :uint32 => UInt32,
    :uint64 => UInt64,
    :sint32 => Int32,
    :sint64 => Int64,
    :bool   => Bool,

    # wire type 1
    :fixed64  => UInt64,
    :sfixed64 => Int64,
    :double   => Float64,

    # wire type 2
    :string => String,
    :bytes  => Slice(UInt8),

    # wire type 5
    :fixed32  => UInt32,
    :sfixed32 => Int32,
    :float    => Float32,
  }

  WIRE_TYPES = {
    :int32  => 0,
    :int64  => 0,
    :uint32 => 0,
    :uint64 => 0,
    :sint32 => 0,
    :sint64 => 0,
    :bool   => 0,

    :fixed64  => 1,
    :sfixed64 => 1,
    :double   => 1,

    :string => 2,
    :bytes  => 2,

    :fixed32  => 5,
    :sfixed32 => 5,
    :float    => 5,
  }
end

require "./protobuf/message"
require "./protobuf/*"