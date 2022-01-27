outputs=test.data.encoded test.data.proto3-encoded test.pb.cr test3.pb.cr

all: $(outputs)

test.data.encoded:
	cat test.data | protoc -I . --encode=Test test.proto > test.data.encoded

test.data.proto3-encoded:
	cat test.data | protoc -I . --encode=TestMessagesV3.Test3 test3.proto > test.data.proto3-encoded

test.pb.cr:
	protoc --crystal_out=. --plugin=protoc-gen-crystal=../../bin/protoc-gen-crystal test.proto
	# The -i switch works differently in GNU vs BSD sed
	sed -i '' 's/^require/# &/g' test.pb.cr || sed -i 's/^require/# &/g' test.pb.cr

test3.pb.cr:
	protoc --crystal_out=. --plugin=protoc-gen-crystal=../../bin/protoc-gen-crystal test3.proto
	sed -i '' 's/^require/# &/g' test3.pb.cr || sed -i 's/^require/# &/g' test3.pb.cr

clean:
	rm -f $(outputs)
