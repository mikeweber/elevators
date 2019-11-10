require_relative '../lib/elevator'

describe Elevator do
  context 'initial state' do
    it 'starts on a floor with doors closed and waiting' do
      expect_elevator_status(Elevator.new, 0, Elevator::WAITING, false)
    end
  end

  context 'when calling for an elevator' do
    it 'opens the doors when called to the current floor' do
      elevator = Elevator.new
      elevator.call_to_floor(0)
      expect_elevator_status(elevator, 0, Elevator::WAITING, false)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::WAITING, true)
    end

    it 'begins the process of going up to the requested floor when called to a higher floor' do
      elevator = Elevator.new
      elevator.call_to_floor(1)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)
    end

    it 'begins the process of going down to the requested floor when called to a lower floor' do
      elevator = Elevator.new
      elevator.call_to_floor(-1)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_DOWN, false)
    end
  end

  context 'when status is going_up' do
    it 'changes the current floor' do
      elevator = Elevator.new
      elevator.call_to_floor(1)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::WAITING, true)
    end

    it 'keeps going up until it has reached the destination floor' do
      elevator = Elevator.new
      elevator.call_to_floor(3)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 3, Elevator::WAITING, true)
    end
  end

  context 'when status is going_down' do
    it 'changes the current floor' do
      elevator = Elevator.new
      elevator.call_to_floor(-1)

      elevator.step!

      expect_elevator_status(elevator,  0, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, -1, Elevator::WAITING, true)
    end

    it 'keeps going down until it has reached the destination floor' do
      elevator = Elevator.new
      elevator.call_to_floor(-3)

      elevator.step!

      expect_elevator_status(elevator,  0, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, -1, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, -2, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, -3, Elevator::WAITING, true)
    end
  end

  context 'when waiting with the doors open' do
    it 'the step method will close the door before going anywhere' do
      elevator = Elevator.new
      elevator.call_to_floor(1)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::WAITING, true)

      elevator.call_to_floor(2)
      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::WAITING, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::WAITING, true)
    end
  end

  context 'when multiple floors are requested at the same time' do
    it 'visits the floors as it reaches each one' do
      elevator = Elevator.new
      expect_elevator_status(elevator, 0, Elevator::WAITING, false)

      elevator.call_to_floor(1)
      elevator.call_to_floor(4)
      elevator.call_to_floor(3)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_UP, true)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 3, Elevator::GOING_UP, true)

      elevator.step!

      expect_elevator_status(elevator, 3, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 4, Elevator::WAITING, true)
    end

    it 'switches from GOING_UP to GOING_DOWN when no more floors are requested above the current_floor' do
      elevator = Elevator.new
      expect_elevator_status(elevator, 0, Elevator::WAITING, false)

      elevator.call_to_floor(2)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_UP, false)

      elevator.call_to_floor(0)
      expect_elevator_status(elevator, 1, Elevator::GOING_UP, false)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::WAITING, true)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::WAITING, false)

      elevator.step!

      expect_elevator_status(elevator, 2, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, 1, Elevator::GOING_DOWN, false)

      elevator.step!

      expect_elevator_status(elevator, 0, Elevator::WAITING, true)
    end
  end

  def expect_elevator_status(elevator, floor, status, open)
    expect(elevator.floor).to eq(floor)
    expect(elevator.status).to eq(status)
    expect(elevator.open?).to eq(open)
  end
end
