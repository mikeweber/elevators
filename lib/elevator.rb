require_relative './door'

class Elevator
  WAITING    = 'waiting'.freeze
  GOING_UP   = 'going_up'.freeze
  GOING_DOWN = 'going_down'.freeze

  private
  attr_writer :floor, :status, :door, :requested_floors

  public

  attr_reader :floor, :status, :door, :requested_floors

  def initialize(door: Door.new, floor: 0)
    self.door             = door
    self.status           = WAITING
    self.floor            = floor
    self.requested_floors = []
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
    door.closed?
  end

  def open?
    door.open?
  end

  def call_to_floor(new_floor)
    requested_floors.push(new_floor)
  end

  def step!
    return close! if open?

    move!
    change_direction!
    arrive_at_floor!
  end

  private

  def move!
    case status
    when GOING_UP
      self.floor += 1
      lock_door!
    when GOING_DOWN
      self.floor -= 1
      lock_door!
    end
  end

  def change_direction!
    return unless waiting? && has_requested_floors?

    self.status = first_requested_floor > floor ? GOING_UP : GOING_DOWN
  end

  def arrive_at_floor!
    return unless on_requested_floor?

    remove_current_floor_from_queue!
    unlock_door!
    open!
    finish_route!
  end

  def has_requested_floors?
    !requested_floors.empty?
  end

  def first_requested_floor
    requested_floors.first
  end

  def finish_route!
    wait! unless more_requested_floors?
  end

  def more_requested_floors?
    if going_up?
      requested_floors.any? { |f| f > floor }
    elsif going_down?
      requested_floors.any? { |f| f < floor }
    end
  end

  def remove_current_floor_from_queue!
    remove_floor_from_queue!(floor)
  end

  def remove_floor_from_queue!(floor_to_remove)
    requested_floors.delete(floor_to_remove)
  end

  def on_requested_floor?
    floor_requested?(floor)
  end

  def floor_requested?(floor)
    requested_floors.include?(floor)
  end

  def wait!
    self.status = WAITING
  end

  def lock_door!
    door.lock!
  end

  def unlock_door!
    door.unlock!
  end

  def open!
    door.open!
  end

  def close!
    door.close!
  end
end
