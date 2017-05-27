# BATTLESHIP GAME
class Game
end

class Player
  def initialize
    @ship_types = { carrier: 5, battleship: 4, cruiser: 3, submarine: 3, destroyer: 2 }
    # DEV : Prefilled hash for development purposes. Reset to empty hash.
    #@my_ship_locations = {:A1=>:carrier, :A2=>:carrier, :A3=>:carrier, :A4=>:carrier, :A5=>:carrier, :B1=>:battleship, :B2=>:battleship, :B3=>:battleship, :B4=>:battleship, :C1=>:cruiser, :C2=>:cruiser, :C3=>:cruiser, :D1=>:submarine, :D2=>:submarine, :D3=>:submarine, :E1=>:destroyer, :E2=>:destroyer}   # Hash[coordinate] = ship_type
    @player_id = 1 # DEV
    @my_ship_locations = {}
    @my_shots_fired = {}      # Hash[coordinate] = hit/miss
  end

  def deploy_ships
    @ship_types.each do |ship|
      puts "Deploy your #{ship[0]} (length #{ship[1]})"
      coordinates = gets.chomp
      redo unless deploy_ship(coordinates, ship)
    end
    puts "All ships succesfully deployed"
    sleep(0.5)
    puts "\n"*40
  end

  # Public: Verify input coordinates and enter into @my_ship_locations and return Boolean.
  #
  # coordinates - String of the format "A1 D1".
  # ship - Two item Array of shipname Symbol and shiplength Integer.
  #
  # Examples
  #
  #   deploy_ship("B2 B4", [:submarine, 3])
  #   # => true
  #
  # Deploys a ship into the Player's game grid
  def deploy_ship(coordinates, ship)
    bow_coordinates, stern_coordinates = coordinates.split
    if stern_coordinates[0] == bow_coordinates[0] # Vertical placement
      letter = stern_coordinates[0]
      stern, bow = stern_coordinates[1].to_i, bow_coordinates[1].to_i
      shipname, shiplength = ship
      if stern - bow == shiplength - 1 # Ship length is correct
        (bow..stern).each do |n|
          coordinate = (letter+n.to_s).to_sym
          @my_ship_locations[coordinate] = shipname
        end
        puts "#{shipname.capitalize} deployed"
        return true
      end
    else
      puts "Nope, try again"
      return false
    end
  end

  private :deploy_ship
end

p1 = Player.new
p1.deploy_ships
