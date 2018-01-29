require "../spec_helper"

require "../fixtures/test.pb"

describe Protobuf::Message do
  describe "#[key]" do
    context "when the key is a member" do
      it "acts as #key" do
        File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
          test = Test.from_protobuf(io)
          test["f1"].should eq("dsfadsafsaf")
        end
      end
    end

    it "works if no fields" do
      empty = EmptyMessage.new
      expect_raises(Protobuf::Error, /Field not found/) do
        empty["blah"]
      end
    end

    context "when the key is not a member" do
      it "raises a runtime error" do
        File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
          test = Test.from_protobuf(io)
          expect_raises(Protobuf::Error, /Field not found/) do
            test["XX"]
          end
        end
      end
    end
  end
end
