class Elevator
  def floor
    0
  end

  def status
    'waiting'
  end

  def open?
    false
  end

  def call_to_floor(new_floor)

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
    end
  end
end
