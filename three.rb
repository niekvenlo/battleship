# BATTLESHIP GAME
# TODO
# 1. Refactor deploy_ship # Done
# 2. Build visualiser
# 3. Fix Game.new mess    # Changed. Not sure it's better
# 4. Rename hit? method   # Let's not

class String
  def color(a)
    case a
    when :green then "\033[32m#{self}\033[0m"
    when :blue  then "\033[36m#{self}\033[0m"
    when :red   then "\033[31m#{self}\033[0m"
    when :white then "\033[37m#{self}\033[0m"
    when :brown then "\033[33m#{self}\033[0m"
    end
  end
end

class Player
  attr_writer :opponent
  attr_reader :my_shots_fired, :player_color

  # Public: Initialize a Player.
  #
  # player_id - An Integer identifying the Player.
  def initialize(player_id)
    @player_id = player_id
    player_colors = [:green, :blue]
    @player_color = player_colors[player_id-1]
    @my_ship_locations = {}
    @my_shots_fired = {}      # Hash[coordinate] = hit/miss
    @opponent
    @ship_types = { carrier: 5 }#, battleship: 4, cruiser: 3, submarine: 3, destroyer: 2 }
  end

  def paint(whose)
    1.upto(10) do |number|
      line = ""
      "A".upto("J") do |letter|
        line << paint_helper(whose, (letter+number.to_s).to_sym)#.center(4)
      end
      puts line
    end
  end

  def paint_helper(whose, position)
    if whose == :mine
      return "▓▓".color :red if @opponent.my_shots_fired.key?(position) && @my_ship_locations.key?(position)
      return "▓▓".color :brown if @opponent.my_shots_fired.key?(position)
      return "▓▓".color :white if @my_ship_locations.key?(position)
      "▓▓".color @player_color
    else
      return "▓▓".color :red if !@opponent.hit?(position).empty? && @my_shots_fired.key?(position)
      return "▓▓".color :brown if @my_shots_fired.key?(position)
      "▓▓".color @opponent.player_color
    end
  end

  # Public: Deploys a Player's ships
  #
  # Returns Boolean
  def deploy_ships
    puts "\nPlayer #{@player_id}:".color @player_color
    paint(:mine)
    @ship_types.each do |ship|
      puts "Deploy your #{ship[0]} (length #{ship[1]})"
      positions = gets.chomp
      redo unless deploy_ship(positions, ship)
      end
    puts "All ships succesfully deployed".freeze
    puts "Press enter".freeze
    gets
    puts "\n"*40
    return true # Why am I doing this?
  end

  # Public: Fires at the opponent
  #
  # Returns a Boolean
  def fire
    paint(:mine)
    paint(:opponent)
    puts "Player #{@player_id} targeting"#.color @player_color
    input = gets.chomp
    target = input.scan(/\b(\w\d)\b/).flatten.map(&:to_sym)
    shots = {}
    target.each do |shot|
      shots[shot] = :splash
    end
    hits = @opponent.hit?(*target)
    hits.each do |hit|
      puts "Hit a #{hit[1].capitalize} at #{hit[0]}!"
      shots[hit.first] = hit.last
    end
    @my_shots_fired.merge!(shots)
    paint(:mine)
    paint(:opponent)
    puts "Press enter"
    gets
    puts "\n"*40
    true
  end

  # Public: Check whether positions in the Player's space are occupied.
  #
  # positions - Receives 1+ Symbols representing game spaces.
  #
  # Examples
  #
  #   hit?(:A1, :D4, E5)
  #   # => { :D4 -> :submarine }
  #
  # Return hash subset of @my_ship_locations
  def hit?(*positions)
    @my_ship_locations.select do |location|
      positions.include?(location)
    end
  end

  private
  # Internal: Verify input coordinates and enter into @my_ship_locations.
  #
  # coordinates - String of the format "A1 D1".
  # ship - Two item Array of shipname Symbol and shiplength Integer.
  #
  # Examples
  #
  #   deploy_ship("B2 B4", [:submarine, 3])
  #   # => true
  #
  # Returns Boolean
  def deploy_ship(positions, ship)
    shipname, shiplength = ship
    letters = positions.scan(/\b(\w)\d\b/).uniq.flatten
    numbers = positions.scan(/\b\w(\d)\b/).uniq.flatten.map(&:to_i)

    return false if (letters + numbers).size != 3
    if letters.size == 1
      orientation = :vertical
      letter = letters.first
      bow, stern = numbers
    elsif numbers.size == 1
      orientation = :horizontal
      number = numbers.first
      bow, stern = letters
    else
      return false
    end

    provisional_ship_locations = {}
    (bow..stern).each do |var|
      number = var if orientation == :vertical
      letter = var if orientation == :horizontal
      coordinate = (letter+number.to_s).to_sym
      provisional_ship_locations[coordinate] = shipname
      return false unless hit?(coordinate).empty?
    end
    @my_ship_locations.merge!(provisional_ship_locations)
    puts "#{shipname.capitalize} deployed"
    paint(:mine)
    return true
  end
end

puts "Welcome to Battleship".freeze
puts "This is a game for two players".freeze

p1 = Player.new(1)
p2 = Player.new(2)

p1.opponent = p2
p2.opponent = p1

p1.deploy_ships
p2.deploy_ships

while true
  p1.fire
  p2.fire
end
