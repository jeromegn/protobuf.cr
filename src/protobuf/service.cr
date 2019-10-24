module Protobuf
  module Service
    class Error < Exception
    end

    class InvalidMethodName < Error
    end

    macro included
      def handle(method_name : String, request_body : IO)
        raise InvalidMethodName.new("Unknown RPC method {{@type.id}}/#{method_name}")
      end

      macro rpc(name, receives, returns)
        abstract def \{{name.stringify.underscore.id}}(request : \{{receives}}) : \{{returns}}

        def handle(method_name : String, request_body : IO)
          if method_name == \{{name.stringify}}
            \{{name.stringify.underscore.id}}(\{{receives}}.from_protobuf(request_body))
          else
            previous_def(method_name, request_body)
          end
        end
      end
    end
  end
end
