class Door
  attr_accessor :held_open, :safe_to_open
  attr_reader :open

  private
  attr_writer :open

  public

  def initialize
    self.open         = false
    self.held_open    = false
    self.safe_to_open = true
  end

  def open!
    return unless safe_to_open?

    self.open = true
  end

  def close!
    return if held_open

    self.open = false
  end

  def closed?
    !open
  end

  def open?
    open
  end

  def safe_to_open?
    safe_to_open
  end
end

