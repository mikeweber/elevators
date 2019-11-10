class Elevator
  WAITING    = 'waiting'.freeze
  GOING_UP   = 'going_up'.freeze
  GOING_DOWN = 'going_down'.freeze

  private
  attr_writer :floor, :status, :open

  public

  attr_reader :floor, :status, :open, :requested_floors

  def initialize
    self.open             = false
    self.status           = WAITING
    self.floor            = 0
    @requested_floors     = []
  end

  def waiting?
    status == WAITING
  end

  def going_up?
    status == GOING_UP
  end

  def going_down?
    status == GOING_DOWN
  end

  def closed?
    !open
  end

  def open?
    open
  end

  def call_to_floor(new_floor)
    requested_floors.push(new_floor)
  end

  def step!
    return close! if open?

    if status == GOING_UP
      self.floor += 1
    elsif status == GOING_DOWN
      self.floor -= 1
    end

    if waiting? && any_requested_floors?
      self.status = first_requested_floor > floor ? GOING_UP : GOING_DOWN
    end

    if floor_requested?(floor)
      remove_floor_from_queue!(floor)
      self.status = WAITING unless more_requested_floors?
      open!
    end
  end

  private

  def any_requested_floors?
    !requested_floors.empty?
  end

  def first_requested_floor
    requested_floors.first
  end

  def more_requested_floors?
    if going_up?
      requested_floors.any? { |f| f > floor }
    elsif going_down?
      requested_floors.any? { |f| f < floor }
    end
  end

  def remove_floor_from_queue!(floor)
    requested_floors.delete(floor)
  end

  def floor_requested?(floor)
    requested_floors.include?(floor)
  end

  def open!
    self.open = true
  end

  def close!
    self.open = false
  end
end
