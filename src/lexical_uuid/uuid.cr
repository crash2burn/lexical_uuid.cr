require "./increasing_microsecond_clock.cr"

require "system"
require "crystal_fnv"

struct LexicalUUID::UUID
  @@worker_id : UInt64 = create_worker_id
  property worker_id : UInt64
  property timestamp : UInt64

  def self.worker_id
    @@worker_id
  end

  def self.create_worker_id : UInt64
    fqdn = System.hostname
    pid = Process.pid
    CrystalFnv::Hash.fnv_1a("#{fqdn}-#{pid}", size: 64).to_u64
  end

  def initialize(bytes : IO)
    @timestamp, @worker_id = from_bytes(bytes)
  end

  def initialize(bytes : String)
    raise Exception.new("ArgumentError") if bytes.size != 36

    @timestamp, @worker_id = from_guid(bytes)
  end

  def initialize(@timestamp : UInt64, @worker_id : UInt64 = self.class.worker_id)
  end

  def initialize
    @worker_id = self.class.worker_id
    @timestamp = IncreasingMicrosecondClock.call
  end

  def to_byte_array
    [
      (timestamp >> 32).to_u32,
      ((timestamp & 0xffffffff) >> 16).to_u16,
      ((timestamp & 0xffffffff)).to_u16,
      (worker_id >> 48).to_u16,
      (worker_id >> 32).to_u16,
      (worker_id & 0xffffffff).to_u32,
    ]
  end

  def to_bytes
    io = IO::Memory.new

    self.to_byte_array.each do |i|
      io.write_bytes(i, IO::ByteFormat::BigEndian)
    end

    io.rewind
  end

  def to_guid
    "%08x-%04x-%04x-%04x-%04x%08x" % self.to_byte_array
  end

  def from_bytes(io)
    time_high = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
    time_low = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
    worker_high = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
    worker_low = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)

    timestamp = ((time_high.to_u64 << 32) | time_low).to_u64
    worker_id = ((worker_high.to_u64 << 32) | worker_low).to_u64

    return timestamp, worker_id
  end

  def from_guid(guid)
    split = guid.split("-")
    timestamp = "#{split[0]}#{split[1]}#{split[2]}".to_u64(16)
    worker_id = "#{split[3]}#{split[4]}".to_u64(16)

    return timestamp, worker_id
  end

  def <=>(other)
    timestamp == other.timestamp ? worker_id <=> other.worker_id : timestamp <=> other.timestamp
  end

  def ==(other)
    other.is_a?(LexicalUUID::UUID) &&
      timestamp == other.timestamp &&
      worker_id == other.worker_id
  end

  def eql?(other)
    self == other
  end

  def hash
    to_bytes.to_s.hash
  end
end
