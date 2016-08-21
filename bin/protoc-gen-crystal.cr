require "../src/protobuf"

STDERR.puts "Generating protobuf classes... (protobuf.cr v#{Protobuf::VERSION})"

req = Protobuf::CodeGeneratorRequest.from_protobuf(STDIN)
res = Protobuf::Generator.compile(req)

STDOUT.print(res.to_protobuf.rewind.to_s)