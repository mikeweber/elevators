require_relative '../lib/elevator'

class Bank
  def elevators
    [Elevator.new]
  end
end

describe Bank do
  it 'can store multiple elevators' do
    bank = Bank.new
    expect(bank.elevators.length).to eq(1)
    expect(bank.elevators.first).to be_a(Elevator)
  end
end
