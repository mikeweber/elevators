class Door
  def closed?
    true
  end
end

describe Door do
  it 'starts closed' do
    door = Door.new
    expect(door).to be_closed
  end

  it 'can be opened' do
    door = Door.new
    expect do
      door.open!
    end.to change { door.open? }.from(false).to(true)
  end
end
