# BATTLESHIP GAME

class Game
  def self.play
    @players = [1,2].map { |i| Player.new(i) }
    @players.each { |player| player.deploy_ships }
    while @players.each { |player| player.fire }
    end
  end

  def self.ship_types
    @ship_types = { carrier: 5, battleship: 4, cruiser: 3, submarine: 3, destroyer: 2 }
  end

  def self.opponent(player_id)
    @players[2-player_id] # Hacky
  end
end

class Player
  # Public: Initialize a Player.
  #
  # player_id - An Integer identifying the Player.
  def initialize(player_id)
    @player_id = player_id
    # DEV : Prefilled hash for development purposes. Reset to empty hash.
    #@my_ship_locations = {:A1=>:carrier, :A2=>:carrier, :A3=>:carrier, :A4=>:carrier, :A5=>:carrier, :B1=>:battleship, :B2=>:battleship, :B3=>:battleship, :B4=>:battleship, :C1=>:cruiser, :C2=>:cruiser, :C3=>:cruiser, :D1=>:submarine, :D2=>:submarine, :D3=>:submarine, :E1=>:destroyer, :E2=>:destroyer}   # Hash[coordinate] = ship_type
    @my_ship_locations = {}
    @my_shots_fired = {}      # Hash[coordinate] = hit/miss
  end

  # Public: Deploys a Player's ships
  #
  # Returns Boolean
  def deploy_ships
    puts "\nPlayer #{@player_id}:"
    Game.ship_types.each do |ship|
      puts "Deploy your #{ship[0]} (length #{ship[1]})"
      positions = gets.chomp
      redo unless deploy_ship(positions, ship)
      end
    puts "All ships succesfully deployed"
    #sleep(0.5)
    #puts "\n"*40
    return true # Why am I doing this?
  end

  # Public: Fires at the opponent
  #
  # Returns a Boolean
  def fire
    opponent = Game.opponent(@player_id)
    puts "Player #{@player_id} targeting"
    input = gets.chomp
    target = input.scan(/\b(\w\d)\b/).flatten.map(&:to_sym)
    hits = opponent.hit?(*target)
    hits.each { |hit| puts "Hit a #{hit[1].capitalize} at #{hit[0]}!" }
    true
  end

  # Internal: Check whether positions in the Player's space are occupied.
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
  def deploy_ship(coordinates, ship)
    letters = coordinates.scan(/\b(\w)\d\b/).uniq.flatten
    numbers = coordinates.scan(/\b\w(\d)\b/).uniq.flatten.map(&:to_i)
    return false if (letters + numbers).length != 3
    shipname, shiplength = ship
    provisional_ship_locations = {}
    if letters.length == 1 # Vertical placement
      letter = letters[0]
      bow, stern = numbers
      if stern - bow == shiplength - 1
        (bow..stern).each do |number|
          coordinate = (letter+number.to_s).to_sym
          provisional_ship_locations[coordinate] = shipname
          return false unless hit?(coordinate).empty?
        end
        @my_ship_locations.merge!(provisional_ship_locations)
        puts "#{shipname.capitalize} deployed"
        return true
      end
    elsif numbers.length == 1 # Horizontal placement
      number = numbers[0]
      bow, stern = letters
      if stern.ord - bow.ord == shiplength - 1
        (bow..stern).each do |letter|
          coordinate = (letter+number.to_s).to_sym
          provisional_ship_locations[coordinate] = shipname
          return false unless hit?(coordinate).empty?
        end
        @my_ship_locations.merge!(provisional_ship_locations)
        puts "#{shipname.capitalize} deployed"
        return true
      end
    else
      puts "Nope, try again"
      return false
    end
  end

end

Game.play
