require_relative '../lib/elevator'

class Bank
  attr_reader :elevators

  private
  attr_writer :elevators

  public

  def initialize(elevators = [Elevator.new])
    self.elevators = elevators
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
  end
end
