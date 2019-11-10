class Door
  def initialize
    @open = false
  end

  def open!
    @open = true
  end

  def close!
    @open = false
  end

  def closed?
    !@open
  end

  def open?
    @open
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
end
