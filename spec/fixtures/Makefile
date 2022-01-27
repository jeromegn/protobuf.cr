outputs=test.data.encoded test.pb.cr test3.pb.cr

all: $(outputs)

test.data.encoded:
	cat test.data | protoc -I . --encode=Test test.proto > test.data.encoded

test.pb.cr:
	protoc --crystal_out=. --plugin=protoc-gen-crystal=../../bin/protoc-gen-crystal test.proto
	sed -i '' 's/^require/# &/g' test.pb.cr

test3.pb.cr:
	protoc --crystal_out=. --plugin=protoc-gen-crystal=../../bin/protoc-gen-crystal test3.proto
	sed -i '' 's/^require/# &/g' test3.pb.cr

clean:
	rm -f $(outputs)
