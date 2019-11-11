class Door
  attr_accessor :held_open
  attr_reader :open, :between_floors_lambda

  private
  attr_writer :open, :between_floors_lambda

  public

  def initialize(between_floors_lambda = nil)
    self.open                  = false
    self.held_open             = false
    self.between_floors_lambda = between_floors_lambda
  end

  def open!
    return if between_floors?

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

  def between_floors?
    return if between_floors_lambda.nil?

    between_floors_lambda.call
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

  it 'can determine when the elevator is between floors' do
    door = Door.new
    expect(door.between_floors?).to be(nil)
  end

  it 'takes in a lambda for determining when an elevator is between floors' do
    door = Door.new(-> { false })
    expect(door.between_floors?).to be(false)

    door = Door.new(-> { true })
    expect(door.between_floors?).to be(true)
  end

  it 'cannot open when it is between floors' do
    door = Door.new(-> { true })
    expect do
      door.open!
    end.to_not change { door.open? }.from(false)

    door = Door.new(-> { false })
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
