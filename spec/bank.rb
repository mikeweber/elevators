require_relative '../lib/elevator'

class Bank
  attr_reader :elevators

  private
  attr_writer :elevators

  public

  def initialize(elevators = [Elevator.new])
    self.elevators = elevators
  end

  def call_to_floor(floor)
    return unless elevator = sorted_eligible_elevators(floor).first

    elevator.call_to_floor(floor)
  end

  def step!
    elevators.each { |el| el.step! }
  end

  def floors
    elevators.map { |el| el.floor }
  end

  def statuses
    elevators.map { |el| el.status }
  end

  def doors_open
    elevators.map { |el| el.open? }
  end

  private

  def sorted_eligible_elevators(requested_floor)
    elevators.select { |el| el.waiting? || el.going_down? && requested_floor < el.floor || el.going_up? && requested_floor > el.floor }.sort_by { |el| (requested_floor - el.floor).abs }
  end
end

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
        bank.call_to_floor(0)
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
        bank.call_to_floor(0)
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
        bank.call_to_floor(0)
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

        bank.call_to_floor(2)

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

        bank.call_to_floor(3)

        bank.step!
        expect(bank.floors).to eq([1, 2, 5, 5])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_DOWN])
        expect(bank.doors_open).to eq([false, false, false, false])

        bank.step!
        expect(bank.floors).to eq([2, 3, 6, 4])
        expect(bank.statuses).to eq([Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_UP, Elevator::GOING_DOWN])
        expect(bank.doors_open).to eq([false, true, false, false])
      end
    end
  end
end
