require "mutex"

MICROSECOND = Time::Span.new(nanoseconds: 1_000)

class LexicalUUID::IncreasingMicrosecondClock
  @time = Time.now

  def initialize(mutex = Mutex.new)
    @mutex = mutex
  end

  def call
    @mutex.synchronize {
      new_time = Time.now

      @time =
        if new_time > @time
          new_time
        else
          @time + MICROSECOND
        end

      (@time.epoch * 1_000_000 + @time.nanosecond/1000).to_u64
    }
  end

  @@instance = new

  def self.call
    @@instance.call
  end
end
