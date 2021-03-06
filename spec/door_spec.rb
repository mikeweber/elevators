require_relative '../lib/door'

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
    door.lock!
    expect(door.safe_to_open?).to be(false)
  end

  it 'can be allowed to open' do
    door = Door.new
    expect(door.safe_to_open?).to be(true)
  end

  it 'cannot open when is unsafe' do
    door = Door.new
    door.lock!
    expect do
      door.open!
    end.to_not change { door.open? }.from(false)

    door.unlock!
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
