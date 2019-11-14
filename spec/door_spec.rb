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

describe Door do
  it 'starts closed' do
    door = Door.new
    expect(door).to be_closed
  end

  it 'can be opened' do
    door = Door.new

    expect do
      door.open!
    end.to change { door.open? }.from(false).to(true)
  end

  it 'can be closed' do
    door = Door.new
    door.open!

    expect do
      door.close!
    end.to change { door.open? }.from(true).to(false)
  end

  it 'can be held open' do
    door = Door.new
    expect(door.held_open).to be(false)

    door.held_open = true

    expect(door.held_open).to be(true)
  end

  it 'can be held closed' do
    door = Door.new
    door.safe_to_open = false
    expect(door.safe_to_open?).to be(false)
  end

  it 'can be allowed to open' do
    door = Door.new
    expect(door.safe_to_open?).to be(true)
  end

  it 'cannot open when is unsafe' do
    door = Door.new
    door.safe_to_open = false
    expect do
      door.open!
    end.to_not change { door.open? }.from(false)

    door.safe_to_open = true
    expect do
      door.open!
    end.to change { door.open? }.from(false).to(true)
  end

  it 'cannot be closed when being held open' do
    door = Door.new
    door.open!

    door.held_open = true

    expect do
      door.close!
    end.to_not change { door.open? }.from(true)
  end
end
