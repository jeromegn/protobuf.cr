module Protobuf
  struct Buffer
    def initialize(@io : IO)
    end

    def skip(wire)
      case wire
      when 0 then read_uint64
      when 1 then read_fixed64
      when 2 then read_string
      when 5 then read_fixed32
      end
    end

    def read_uint64
      n = shift = 0_u64
      loop do
        if shift >= 64
          raise Error.new("buffer overflow varint")
        end
        byte = @io.read_byte
        if byte.nil?
          return nil
        end
        b = byte.unsafe_chr.ord

        n |= ((b & 0x7F).to_u64 << shift)
        shift += 7
        if (b & 0x80) == 0
          return n.to_u64
        end
      end
    end

    def read_uint32
      n = read_uint64
      return nil if n.nil?
      n.to_u32!
    end

    def read(n : Int32)
      slice = Slice(UInt8).new(n)
      @io.read_fully(slice)
      slice
    end

    def read_string
      bytes = read_bytes
      return nil if bytes.nil?
      String.new(bytes)
    end

    def read_fixed32
      @io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed32
      @io.read_bytes(Int32, IO::ByteFormat::LittleEndian)
    end

    def read_fixed64
      @io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
    end

    def read_sfixed64
      @io.read_bytes(Int64, IO::ByteFormat::LittleEndian)
    end

    def read_float
      @io.read_bytes(Float32, IO::ByteFormat::LittleEndian)
    end

    def read_double
      @io.read_bytes(Float64, IO::ByteFormat::LittleEndian)
    end

    def read_int64
      n = read_uint64
      return nil if n.nil?
      if n > Int64::MAX
        n -= Int64::MAX.to_u64 + 1_u64
      end
      n.to_i64!
    end

    def read_int32
      n = read_int64
      return nil if n.nil?
      n.to_i32!
    end

    def read_sint32
      n = decode_zigzag(read_uint32)
      return nil if n.nil?
      n.to_i32!
    end

    def read_sint64
      n = decode_zigzag(read_uint64)
      return nil if n.nil?
      n.to_i64!
    end

    def read_bool
      @io.read_byte == 1
    end

    def new_from_length
      slice = read_bytes
      return nil if slice.nil?
      Protobuf::Buffer.new IO::Memory.new(slice)
    end

    def decode_zigzag(value)
      return nil if value.nil?
      return value >> 1 unless value & 0x1
      value >> 1 ^ (~0)
    end

    def read_bytes
      n = read_int32
      return nil if n.nil?
      read(n)
    end

    def read_info
      n = read_uint64
      return {nil, nil} if n.nil?
      tag = n >> 3
      wire = (n & 0x7)

      {tag, wire}
    end


    def write_uint64(n : UInt64)
      loop do
        bits = n & 0x7F
        n >>= 7
        if n == 0
          @io.write_byte(bits.to_u8!)
          break
        end
        @io.write_byte (bits | 0x80).to_u8!
      end
    end

    def write_uint32(n : UInt32)
      write_uint64(n.to_u64)
    end

    def write_string(str : String)
      write_bytes(str.encode("UTF-8"))
    end

    def write_fixed32(n : UInt32)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_fixed64(n : UInt64)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_sfixed32(n : Int32)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_sfixed64(n : Int64)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_float(n : Float32)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_double(n : Float64)
      @io.write_bytes(n, IO::ByteFormat::LittleEndian)
    end

    def write_int64(n : Int64)
      n += (1 << 64) if n < 0
      write_uint64(n.to_u64!)
    end

    def write_int32(n : Int32)
      write_uint64(n.to_u64!)
    end

    def write_sint32(n : Int32)
      write_uint64(((n << 1) ^ (n >> 31)).to_u64!)
    end

    def write_sint64(n : Int64)
      write_uint64(((n << 1) ^ (n >> 63)).to_u64!)
    end

    def write_bool(b : Bool)
      @io.write_byte b ? 1_u8 : 0_u8
    end

    def write_bytes(bytes : Slice(UInt8))
      write_uint64(bytes.bytesize.to_u64!)
      @io.write(bytes)
    end

    def write_io(io : IO)
      IO.copy(io, @io)
    end

    def write_packed(arr, pb_type)
      io = IO::Memory.new
      tmp_buf = self.class.new(io)
      arr.not_nil!.each {|i| tmp_buf.write(i, pb_type) }
      write_uint64(io.bytesize.to_u64!)
      write_io(io.rewind)
    end

    def write_message(msg : Protobuf::Message)
      io = msg.to_protobuf
      write_uint64(io.bytesize.to_u64!)
      write_io(io.rewind)
    end

    def write_message(e : Enum)
      write_enum(e)
    end

    def write_enum(e : Enum)
      e.to_protobuf(@io)
    end

    def write_info(tag : Int32, wire : Int32)
      write_uint64 (tag << 3 | wire).to_u64!
    end

    def write(value, pb_type)
      case {value, pb_type}

      when {Int32, :int32}; write_int32(value)
      when {Int32, :sint32}; write_sint32(value)

      when {Int64, :int64}; write_int64(value)
      when {Int64, :sint64}; write_sint64(value)

      when {UInt32, :uint32}; write_uint32(value)
      when {UInt32, :fixed32}; write_fixed32(value)

      when {UInt64, :uint64}; write_uint64(value)
      when {UInt64, :fixed64}; write_fixed64(value)

      when {Float32, :float}; write_float(value)
      when {Float64, :double}; write_double(value)

      when {Slice(UInt8), :bytes}; write_bytes(value)
      when {String, :string}; write_string(value)

      when {Bool, :bool}; write_bool(value)

      else
        raise Error.new("Crystal type #{value.class} and protobuf type #{pb_type} mismatch")
      end
    end
  end
end
