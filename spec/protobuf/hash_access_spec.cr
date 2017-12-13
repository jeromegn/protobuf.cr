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

  describe "#[key]=(val)" do
    context "when the key is a member and the val type is valid" do
      it "acts as #key=" do
        File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
          test = Test.from_protobuf(io)
          test["f1"] = "foo"
          test["f1"].should eq("foo")
          test.f1.should eq("foo")

          test["f2"] = -1_i64
          test["f2"].should eq(-1_i64)
          test.f2.should eq(-1_i64)
        end
      end
    end

    context "when the key is a member but the val type is mismatch" do
      it "raises ArgumentError" do
        File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
          test = Test.from_protobuf(io)
          expect_raises(ArgumentError, "f1 expected `String`, but got `Int32`") do
            test["f1"] = 2
          end

          expect_raises(ArgumentError, "f2 expected `Int64`, but got `String`") do
            test["f2"] = "foo"
          end
        end
      end
    end

    context "when the key is not a member" do
      it "raises a runtime error" do
        File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
          test = Test.from_protobuf(io)
          expect_raises(Protobuf::Error, /Field not found/) do
            test["XX"] = nil
          end
        end
      end

      it "works if no fields" do
        empty = EmptyMessage.new
        expect_raises(Protobuf::Error, /Field not found/) do
          empty["XX"] = nil
        end
      end
    end
  end

  describe "#to_hash" do
    it "returns a Hash(String, _)" do
      File.open("#{__DIR__}/../fixtures/test.data.encoded") do |io|
        test = Test.from_protobuf(io)
        hash = test.to_hash

        hash.is_a?(Hash).should be_true

        # sample testing
        hash.select{|k,v| k =~ /^f[12]$/}.should eq({"f1" => "dsfadsafsaf", "f2" => 234})

        # ensures that both hash and pb have same values for all keys
        hash.keys.each do |k|
          hash[k].should eq(test[k])
        end
      end
    end

    it "works if no fields" do
      empty = EmptyMessage.new
      hash = empty.to_hash

      hash.is_a?(Hash).should be_true
      hash.empty?.should be_true
    end
  end
end
