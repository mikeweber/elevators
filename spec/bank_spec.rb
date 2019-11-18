require_relative '../lib/bank'

describe Bank do
  it 'can store multiple elevators' do
    bank = Bank.new
    expect(bank.elevators.length).to eq(1)
    expect(bank.elevators.first).to be_a(Elevator)

    elevators = [Elevator.new, Elevator.new, Elevator.new]
    bank = Bank.new(elevators)
    expect(bank.elevators.length).to eq(3)
    expect(bank.elevators.first).to be_a(Elevator)
    expect(bank.elevators.last).to be_a(Elevator)
  end

  context 'when calling for an elevator' do
    it 'calls the first elevator in the list' do
      el1 = Elevator.new
      el2 = Elevator.new
      bank = Bank.new([el1, el2])

      expect do
        bank.call_to_floor(0, :up)
        bank.step!
      end.to change { el1.open? }.from(false).to(true)
      expect(el2).to be_closed
    end

    it 'calls the first available elevator' do
      el1 = Elevator.new
      el2 = Elevator.new
      bank = Bank.new([el1, el2])

      el1.call_to_floor(1)
      el1.step!

      expect(el1.floor).to eq(0)
      expect do
        bank.call_to_floor(0, :up)
        bank.step!
      end.to change { el2.open? }.from(false).to(true)
      expect(el1.floor).to_not eq(0)
    end

    it 'calls the closest' do
      el1 = Elevator.new(floor:  2)
      el2 = Elevator.new(floor: -1)
      bank = Bank.new([el1, el2])

      expect(el1.status).to eq(Elevator::WAITING)
      expect do
        bank.call_to_floor(0, :up)
        bank.step!
      end.to change { el2.status }.from(Elevator::WAITING).to(Elevator::GOING_UP)
      expect(el1.status).to eq(Elevator::WAITING)
    end

    context 'and all elevators are busy' do
      it 'calls the closest elevator that is heading down to the requested floor' do
        el1 = Elevator.new(floor:  5) # This is the closest elevator on the way
        el2 = Elevator.new(floor:  6)
        el3 = Elevator.new(floor:  0)
        el4 = Elevator.new(floor: -2)
        bank = Bank.new([el1, el2, el3, el4])

        el1.call_to_floor(-1)
        el2.call_to_floor(-1)
        el3.call_to_floor(-1)
        el4.call_to_floor(10)
        bank.step!

        expect(el1.status).to eq(Elevator::GOING_DOWN)
        expect(el2.status).to eq(Elevator::GOING_DOWN)
        expect(el3.status).to eq(Elevator::GOING_DOWN)
        expect(el4.status).to eq(Elevator::GOING_UP)

        bank.call_to_floor(2, :down)

        bank.step!
        expect(bank.floors).to eq([4, 5, -1, -1])
        expect(bank.statuses).to eq([Elevator::GOING_DOWN, Elevator::GOING_DOWN, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, true, false])

        bank.step!
        expect(bank.floors).to eq([3, 4, -1, 0])
        expect(bank.statuses).to eq([Elevator::GOING_DOWN, Elevator::GOING_DOWN, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, false, false])

        bank.step!
        expect(bank.floors).to eq([2, 3, -1, 1])
        expect(bank.statuses).to eq([Elevator::GOING_DOWN, Elevator::GOING_DOWN, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([true, false, false, false])
      end

      it 'calls the closest elevator that is heading up to the requested floor' do
        el1 = Elevator.new(floor: 0)
        el2 = Elevator.new(floor: 1) # This is the closest elevator on the way
        el3 = Elevator.new(floor: 4)
        el4 = Elevator.new(floor: 6)
        bank = Bank.new([el1, el2, el3, el4])

        el1.call_to_floor(10)
        el2.call_to_floor(10)
        el3.call_to_floor(10)
        el4.call_to_floor(0)
        bank.step!

        expect(el1.status).to eq(Elevator::GOING_UP)
        expect(el2.status).to eq(Elevator::GOING_UP)
        expect(el3.status).to eq(Elevator::GOING_UP)
        expect(el4.status).to eq(Elevator::GOING_DOWN)

        bank.call_to_floor(3, :up)

        bank.step!
        expect(bank.floors).to eq([1, 2, 5, 5])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_DOWN])
        expect(bank.doors_open).to eq([false, false, false, false])

        bank.step!
        expect(bank.floors).to eq([2, 3, 6, 4])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_DOWN])
        expect(bank.doors_open).to eq([false, true, false, false])
      end

      it 'waits for the next eligible elevator when none exist at the time of the call' do
        el1 = Elevator.new(floor: 1)
        el2 = Elevator.new(floor: 2) # This elevator will finish its route first
        el3 = Elevator.new(floor: 3)
        bank = Bank.new([el1, el2, el3])

        el1.call_to_floor(6)
        el2.call_to_floor(3)
        el3.call_to_floor(10)
        bank.step!

        expect(el1.status).to eq(Elevator::GOING_UP)
        expect(el2.status).to eq(Elevator::GOING_UP)
        expect(el3.status).to eq(Elevator::GOING_UP)

        # elevator 1 should not respond since it's already in motion, even though
        # it's already on the requested floor
        bank.call_to_floor(1, :up)

        bank.step!
        expect(bank.floors).to eq([2, 3, 4])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, true, false])

        bank.step!
        expect(bank.floors).to eq([3, 3, 5])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, false])

        bank.step!
        expect(bank.floors).to eq([4, 3, 6])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_DOWN, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, false])

        bank.step!
        expect(bank.floors).to eq([5, 2, 7])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_DOWN, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, false])

        bank.step!
        expect(bank.floors).to eq([6, 1, 8])
        expect(bank.statuses).to eq([Elevator::WAITING, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([true, true, false])

        bank.step!
        expect(bank.floors).to eq([6, 1, 9])
        expect(bank.statuses).to eq([Elevator::WAITING, Elevator::WAITING, Elevator::GOING_UP])
        expect(bank.doors_open).to eq([false, false, false])
      end

      it 'only calls elevator heading in the same direction as the request' do
        el1 = Elevator.new(floor: 1)
        el2 = Elevator.new(floor: 2)
        el3 = Elevator.new(floor: 6) # This elevator is the only one going down
        bank = Bank.new([el1, el2, el3])

        el1.call_to_floor(6)
        el2.call_to_floor(3)
        el3.call_to_floor(0)
        bank.step!

        expect(el1.status).to eq(Elevator::GOING_UP)
        expect(el2.status).to eq(Elevator::GOING_UP)
        expect(el3.status).to eq(Elevator::GOING_DOWN)

        bank.call_to_floor(1, :down)
      end
    end
  end
end
