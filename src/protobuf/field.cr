module Protobuf
  struct Field(T)
    getter name, value, proto_type

    def initialize(@name : String, @proto_type : Symbol? = nil)
    end

    # def decode(io)
    #   T.decode(io)
    # end
  end
end
