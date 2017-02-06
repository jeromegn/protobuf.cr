abstract struct Enum
  def self.new(buf : Protobuf::Buffer)
    new(buf.read_int32.not_nil!)
  end

  def self.from_protobuf(io : IO)
    new(Protobuf::Buffer.new(io))
  end

  def to_protobuf(io : IO, embedded = true)
    buf = Protobuf::Buffer.new(io)
    buf.write_uint64(self.to_i.to_u64)
  end

  def to_protobuf(embedded = true)
    io = IO::Memory.new
    to_protobuf(io, embedded)
  end
end
