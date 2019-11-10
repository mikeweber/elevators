class Elevator
  def initialize
    @open   = false
    @status = 'waiting'
  end

  def floor
    0
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
    else
      @status = 'going_up'
    end
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
  end
end
