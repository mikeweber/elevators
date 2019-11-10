class Elevator
  WAITING    = 'waiting'.freeze
  GOING_UP   = 'going_up'.freeze
  GOING_DOWN = 'going_down'.freeze

  def initialize
    @open   = false
    @status = WAITING
    @floor  = 0
  end

  def floor
    @floor
  end

  def status
    @status
  end

  def open?
    @open
  end

  def call_to_floor(new_floor)
    if floor == new_floor
      open!
    elsif new_floor > floor
      @status = GOING_UP
    elsif new_floor < floor
      @status = GOING_DOWN
    end
  end

  def step!
    @floor += 1
    @status = WAITING
    open!
  end

  private

  def open!
    @open = true
  end
end

describe Elevator do
  context 'initial state' do
    it 'starts on a floor' do
      elevator = Elevator.new
      expect(elevator.floor).to eq(0)
    end

    it 'starts with a status of waiting' do
      elevator = Elevator.new
      expect(elevator.status).to eq('waiting')
    end

    it 'starts with the doors closed' do
      elevator = Elevator.new
      expect(elevator).to_not be_open
    end
  end

  context 'when calling for an elevator' do
    it 'opens the doors when called to the current floor' do
      elevator = Elevator.new
      elevator.call_to_floor(0)
      expect(elevator.floor).to eq(0)
      expect(elevator.status).to eq('waiting')
      expect(elevator).to be_open
    end

    it 'begins the process of going up to the requested floor when called to a higher floor' do
      elevator = Elevator.new
      elevator.call_to_floor(1)
      expect(elevator.floor).to eq(0)
      expect(elevator.status).to eq('going_up')
      expect(elevator).to_not be_open
    end

    it 'begins the process of going down to the requested floor when called to a lower floor' do
      elevator = Elevator.new
      elevator.call_to_floor(-1)
      expect(elevator.floor).to eq(0)
      expect(elevator.status).to eq('going_down')
      expect(elevator).to_not be_open
    end
  end

  context 'when status is going_up' do
    it 'changes the current floor' do
      elevator = Elevator.new
      elevator.call_to_floor(1)
      expect(elevator.floor).to eq(0)
      expect(elevator.status).to eq('going_up')
      expect(elevator).to_not be_open

      elevator.step!

      expect(elevator.floor).to eq(1)
      expect(elevator.status).to eq('waiting')
      expect(elevator).to be_open
    end

    it 'keeps going up until it has reached the destination floor' do
      elevator = Elevator.new
      elevator.call_to_floor(3)
      expect(elevator.floor).to eq(0)
      expect(elevator.status).to eq('going_up')
      expect(elevator).to_not be_open

      elevator.step!

      expect(elevator.floor).to eq(1)
      expect(elevator.status).to eq('going_up')
      expect(elevator).to_not be_open

      elevator.step!

      expect(elevator.floor).to eq(2)
      expect(elevator.status).to eq('going_up')
      expect(elevator).to_not be_open

      elevator.step!

      expect(elevator.floor).to eq(3)
      expect(elevator.status).to eq('waiting')
      expect(elevator).to be_open
    end
  end
end
