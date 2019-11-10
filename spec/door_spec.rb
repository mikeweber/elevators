class Door

end

describe Door do
  it 'starts closed' do
    door = Door.new
    expect(door).to be_closed
  end
end
