class Duration
  include Comparable
  attr_reader :seconds

  # Factory method that takes a number of seconds
  def self.seconds(seconds)
    new seconds
  end

  def self.minutes(minutes)
    new (minutes * 60)
  end

  def initialize(seconds)
    @seconds = seconds
  end

  def -(other)
    Duration.seconds(seconds - other.seconds)
  end

  def *(number)
    Duration.seconds(seconds * number)
  end

  def /(other)
    seconds / other.seconds.to_f
  end

  def <=>(other)
    seconds <=> other.seconds
  end

  def to_f
    seconds.to_f
  end

  def to_s(format=:default)
    minutes, seconds = self.seconds.divmod 60
    hours, minutes = minutes.divmod 60
    send("#{format}_format", hours, minutes, seconds)
  end

  def default_format(hours, minutes, seconds)
    if hours.zero?
      format '%02d:%02d', minutes, seconds
    else
      format '%d:%02d:%02d', hours, minutes, seconds
    end
  end

  def no_hours_format(hours, minutes, seconds)
    format '%02d:%02d', (hours * 60) + minutes, seconds
  end

  def ==(other)
    eql?(other)
  end

  def eql?(other)
    self.class == other.class && seconds == other.seconds
  end

  def hash
    seconds.hash
  end

  def minutes
    seconds / 60
  end
end