class Elevator

end

describe Elevator do
  it 'starts on a floor' do
    elevator = Elevator.new
    expect(elevator.floor).to eq(0)
  end
end
