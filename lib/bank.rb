require_relative './elevator'

class Bank
  attr_reader :elevators

  private
  attr_writer :elevators

  public

  def initialize(elevators = [Elevator.new])
    self.elevators = elevators
    @queue = []
  end

  def call_to_floor(floor, direction)
    return add_to_queue!(floor, direction) unless elevator = sorted_eligible_elevators(floor).first

    elevator.call_to_floor(floor)
  end

  def step!
    old_queue = @queue
    @queue = []

    elevators.each { |el| el.step! }
    old_queue.each { |floor, dir| call_to_floor(floor, dir) }
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

  def add_to_queue!(floor, dir)
    @queue << [floor, dir]
  end
end
