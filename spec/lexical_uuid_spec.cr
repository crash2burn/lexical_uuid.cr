require "./spec_helper"

describe LexicalUUID do
  describe "creating a UUID with no parameters" do
    uuid = LexicalUUID::UUID.new

    it "has a worker id" do
      uuid.worker_id.should_not be_nil
    end

    it "has a timestamp in usecs" do
      uuid.timestamp.should be < LexicalUUID::IncreasingMicrosecondClock.call
    end
  end

  describe "reinitializing the uuid from bytes" do
    describe "with a correctly sized byte array" do
      bytes = [1234567890 >> 32,
               1234567890 & 0xffffffff,
               (9876543210 >> 32).to_i32,
               (9876543210 & 0xffffffff).to_i32]

      io = IO::Memory.new

      bytes.each do |i|
        io.write_bytes(i, IO::ByteFormat::BigEndian)
      end

      uuid = LexicalUUID::UUID.new(io.to_slice)

      it "correctly extracts the timestamp" do
        uuid.timestamp.should eq 1234567890
      end

      it "correctly extracts the worker id" do
        uuid.worker_id.should eq 9876543210
      end
    end

    describe "with a mis-sized byte array" do
      it "raises ArgumentError" do
        ex = nil
        begin
          l = LexicalUUID::UUID.new("asdf")
        rescue e : Exception
          ex = e
        end

        ex.should_not be nil
      end
    end

    describe "converting a uuid in to a guid" do
      uuid = LexicalUUID::UUID.new
      uuid.timestamp = 15463021018891620831
      uuid.worker_id = 9964740229835689317

      it "matches other uuid->guid implementations" do
        uuid.to_guid.should eq "d697afb0-a96f-11df-8a49-de718e668d65"
      end
    end

    describe "initializing from a guid" do
      uuid = LexicalUUID::UUID.new("d697afb0-a96f-11df-8a49-de718e668d65")

      it "correctly initializes the timestamp" do
        uuid.timestamp.should eq 15463021018891620831
      end

      it "correctly initializes the worker_id" do
        uuid.worker_id.should eq 9964740229835689317
      end
    end

    describe "comparing uuids" do
      it "compares first by timestamp" do
        (LexicalUUID::UUID.new(123_u64) <=> LexicalUUID::UUID.new(234_u64)).should eq -1
        (LexicalUUID::UUID.new(223_u64) <=> LexicalUUID::UUID.new(134_u64)).should eq 1
      end

      it "compares by worker_id if the timestamps are equal" do
        (LexicalUUID::UUID.new(123_u64, 1_u64) <=> LexicalUUID::UUID.new(123_u64, 2_u64)).should eq -1
        (LexicalUUID::UUID.new(123_u64, 2_u64) <=> LexicalUUID::UUID.new(123_u64, 1_u64)).should eq 1
        (LexicalUUID::UUID.new(123_u64, 1_u64) <=> LexicalUUID::UUID.new(123_u64, 1_u64)).should eq 0
      end
    end

    describe "==" do
      it "is equal when the timestamps and worker ids are equal" do
        LexicalUUID::UUID.new(123_u64, 123_u64).should eq LexicalUUID::UUID.new(123_u64, 123_u64)
      end

      it "is not equal when the timestamps are not equal" do
        LexicalUUID::UUID.new(223_u64, 123_u64).should_not eq LexicalUUID::UUID.new(123_u64, 123_u64)
      end

      it "is not equal when the worker_ids are not equal" do
        LexicalUUID::UUID.new(123_u64, 223_u64).should_not eq LexicalUUID::UUID.new(123_u64, 123_u64)
      end
    end

    describe "eql?" do
      it "is equal when the timestamps and worker ids are equal" do
        LexicalUUID::UUID.new(123_u64, 123_u64).should eq (LexicalUUID::UUID.new(123_u64, 123_u64))
      end

      it "is not equal when the timestamps are not equal" do
        LexicalUUID::UUID.new(223_u64, 123_u64).should_not eq (LexicalUUID::UUID.new(123_u64, 123_u64))
      end

      it "is not equal when the worker_ids are not equal" do
        LexicalUUID::UUID.new(123_u64, 223_u64).should_not eq (LexicalUUID::UUID.new(123_u64, 123_u64))
      end
    end

    describe "hash" do
      it "has the same hash if the timestamp/worker_id are the same" do
        LexicalUUID::UUID.new(123_u64, 123_u64).hash.should eq LexicalUUID::UUID.new(123_u64, 123_u64).hash
      end

      it "has a different hash when the timestamps are different" do
        LexicalUUID::UUID.new(223_u64, 123_u64).hash.should_not eq LexicalUUID::UUID.new(123_u64, 123_u64).hash
      end

      it "has a different hash when the worker_ids are not equalc" do
        LexicalUUID::UUID.new(123_u64, 223_u64).hash.should_not eq LexicalUUID::UUID.new(123_u64, 123_u64).hash
      end
    end
  end
end
