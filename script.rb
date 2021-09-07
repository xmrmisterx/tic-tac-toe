class Board # Board class is responsible for initializing the board with a grid and placing pieces on the board.
  
  def initialize # We initialize by creating an array of 3 elements, each element being an array itself of 3 "nil" elements.
      @board = Array.new(3){Array.new(3)}

  end

  def render # This function draws the grid in our game, with any associated pieces already there staying intact.
    puts

    @board.each do |row|
        row.each do |cell|

            cell.nil? ? print("-") : print(cell.to_s)
        end
        puts
    end
    puts
  end

  def place_piece (arr2, piece) # This function will place the player's piece ("x" or "o") onto the board. Note the parameters of an array and a piece. The arr2 is actually the coordinates of where to place the piece, so we set the x part of the coordinate as the first part of our coordinate, and the y part of the coordinate as the second part of the coordinate, in our board. Because our board is a multidimensional array, "@board[xcoordinate][ycoordinate]" is the notation for placing the piece in the correct spot.

    @board[arr2[0]][arr2[1]]= piece

  end
end

class Game # The game class is the main class, containing most of our functions.

  def initialize # When we start the game, we want to create a new board, then render it so the player sees it. We'll also ask the human player for their name, then create the players, assign the current player, and announce the player names and their pieces.
    
    @board = Board.new
    @board.render

    puts "Player1, what is your name?" 
    player1_name = gets.chomp 

    @player1 = Player.new(player1_name, "x") 
    @player2 = Player.new("computer", "o")
    @current_player = @player1
    puts "Player one's name is #{@player1.name} and they control the #{@player1.piece} piece. Player two is the #{@player2.name} and they control the #{@player2.piece} piece"
  
  end

  def play # This is our main function of the game, the "play" function. It alternates between the two players, asking for coordinates, placing them, and checking for game winning combinations after each piece placement.

    coordinates_taken_counter = 0 # We have a coordinates_taken_counter, which keeps track of how many coordinates have been placed. Once this is at 9 or greater, that means the game is over and ended in a tie.
    coordinates_taken_array = [] # We need a coordinates_taken_array to keep track of which coordinates have been taken. Once a piece is placed, the coordinate for that piece goes into this array.
    coordinate_with_piece_hash = {

      [0,0] => nil,
      [0,1] => nil,
      [0,2] => nil,
      [1,0] => nil,
      [1,1] => nil,
      [1,2] => nil,
      [2,0] => nil,
      [2,1] => nil,
      [2,2] => nil
    
    } # The coordinates_with_piece_hash is how we'll check for game winning combinations. It keeps track of each coordinate as the key, and the value is the piece that is on that coordinate, if a piece is placed, otherwise the value will be nil.
    
    available_coordinates_array = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]] # We also need an available coordinates array, which tracks which coordinates still don't have pieces on them. This is used by the computer to determine the available coordinates.

    loop do # We want a game loop that will keep asking players for coordinates, until there is a tie or a winner.

      if @current_player == @player1 # We have an if statement to check which player it is, since player 2 is controlled by the computer

        puts "#{@current_player.name} please input the coordinates for your piece in coordinate form (x,y), where x and y have values from 0 to 2." # We ask the human player, player 1, for their coordinates of choice.
        answer1 = gets.chomp # The coordinate is saved as answer1...
        filtered_coordinate = Game.filter(answer1) # then we run our class method "filter" to remove commas and other irrelevant characters, to leave a "filtered_coordinate"
      
        if Game.coordinates_valid?(filtered_coordinate) # We run the "coordinates_valid?" method on our filtered_coordinate to see if the answer is a possible coordinate on the board.

          converted_coordinate = Game.convert_coordinate(filtered_coordinate) # then we run the class method "convert_cordinate" on the filtered coordinate that leaves us with a "converted_coordinate"
        
        else # If the coordinates are not valid, we say so.
          puts "Those are not valid coordinates, try again..."
          redo
        end
      end
      
      if @current_player == @player2 # If the current player is player 2, or the computer...

        puts "The computer is thinking about which coordinate to pick..." # we puts out a message saying the computer is thinking...
        sleep(5) # then pause the code for 5 seconds to make it seem like the computer is thinking, lol.

        converted_coordinate = Game.computer_pick(available_coordinates_array) # We run the class method computer pick, which relies on the available coordinates array parameter, to get the computer's "converted_coordinate"

      end

      if Game.coordinates_taken?(converted_coordinate, coordinates_taken_array) == false # We run the class method "coordinates_taken?" to see if the coordinate, although valid, is already taken on the board...

        available_coordinates_array = available_coordinates_array - converted_coordinate # We update our available coordinates array equal to itself minus the coordinate we will be placing a piece on.

        coordinate_with_piece_hash[converted_coordinate] = @current_player.piece # Here, we update our coordinate_with_piece hash, for the key at the "converted_coordinate" to have a value equal to the current player's piece.

        coordinates_taken_array = Game.add_coordinate(converted_coordinate, coordinates_taken_array) # We call the class method "add_coordinate" to add our converted_coordinate to our coordinates_taken_array

        @board.place_piece(converted_coordinate, @current_player.piece) # We call the place piece function from our "@board" object to place a piece at the converted coordinate
        @board.render # then render the board so we can see it.

        if Game.game_over?(coordinate_with_piece_hash) # After the piece is placed, we run the class method "game_over?" to check if their is a winner. If there is...
          puts "#{@current_player.name} has 3 in a row and is the winner! Game over..." # We declare the winner and end the game...
          break # and break our play loop.
        end

        switch_players  # If there isn't a winner yet, we call the Player class method "switch_players" to switch the current player.

        coordinates_taken_counter += 1 # We tick up the coordinates taken counter to keep track of how many pieces are on the board.
      
        if coordinates_taken_counter >= 9 # If there are 9 or more pieces on the board... the game is over and has resulted in a tie.
          puts "All possible coordinates are taken and the game has ended in a tie"
          break
        end

      else # If the converted coordinate is taken... We tell the player to try again.
        puts "Those are valid coordinates, but they are taken... Try again."
      end
    end
  end

  def switch_players # We need a function to switch players after every piece. We check to see if the current player is player1, and if it is, set current player to player1, otherwise if the current player is not player1, we set current player to player 1.
    if @current_player == @player1
      @current_player = @player2
    else
      @current_player = @player1
    end
  
  end


  def self.filter (answer_string) # Our filter method breaks down the players coordinate string into individual characters, takes only the relevant characters, and returns them as a "filtered_array".
    answer_array = answer_string.chars # Break the answer string down into individual characters and set them equal to an "answer_array"
    filtered_array = [] # We declare an empty filtered array, so we can push characters into it.

    answer_array.each do |character| # Loop through each "character" in the answer array...
      if character == "0" || character == "1" || character == "2" # If the string is a 0, 1, or 2 (the only possible values for our tic tac toe coordinates)...
        filtered_array.push(character.to_i) # Change the character into an integer, and push it into the filtered array.

      end
    end

    return filtered_array # Explicitly return the filtered array, so we can call this method when we want the filtered array.
  end

  def self.convert_coordinate(filtered_array) # This method takes the filtered array as a parameter, and converts the coordinate key into its associated coordinate value. We have to convert the coordinates because the computer coordinate system, and our standard coordinate system, is not the same.

    coordinate_conversion_hash = { # These are the key value pairs for standard notation coordinates and our board's coordinates, respectively.

      [0,0] => [2,0],
      [1,0] => [2,1],
      [2,0] => [2,2],
      [0,1] => [1,0],
      [1,1] => [1,1],
      [2,1] => [1,2],
      [0,2] => [0,0],
      [1,2] => [0,1],
      [2,2] => [0,2],
    }

    coordinate_conversion_hash.each do |key, value|  # We loop through our hash and find the key that matches the filtered array, and return the value associated with that key.
      if key == filtered_array
        return value
      end
    end
  end

  def self.coordinates_valid?(arr) # This function checks to see if the coordinates input by the player are valid, after we have converted it into a filtered array.
    if (arr[0] != nil && arr[0] >= 0 && arr[0] <=2) && (arr[1] != nil && arr[1] >= 0 && arr[1] <=2) # If index 0 of the filtered array, which is equal to x coordinate, is not nil and between 0 and 2 inclusive, then it is valid. The same criteria apply for index 1 of our filtered array, which corresponds to the y coordinate.
      return true
    else return false
    end
  end

  
  def self.coordinates_taken?(converted_coordinate, coordinates_taken_array) # We also need a check to see if our converted coordinate is already taken on the board...
    coordinates_taken_array.each do |coordinate| # We loop through each "coordinate" of our coordinates_taken_array...
      if converted_coordinate == coordinate # If the converted coordinate is equal to a coordinate in our coordinates_taken_array...

        return true # then the converted coordinate is taken.
      end
      
    end
  
    return false # If none of the coordinates match our converted coordinate, then our converted coordinate is not taken.
  end

  def self.add_coordinate (converted_coordinate, coordinates_taken_array) # "Add_coordinate" adds our to be placed coordinate into the coordinates_taken_array.
    if coordinates_taken?(converted_coordinate, coordinates_taken_array) == false # If our converted coordinate is not taken...
  
      coordinates_taken_array.push(converted_coordinate)   # add our converted coordinate into our coordinates taken array.
  
    end
    return coordinates_taken_array # We want to return the coordinates_taken_array to call it using this function.
  end

  def self.check_for_winner (coord1, coord2, coord3, coordinate_with_piece_hash)   # This function checks coordinates 1, 2, and 3, for a winning combination of 3 in a row, using the coordinate_with_piece_hash to check each coordinates corresponding piece.
  
    if (coordinate_with_piece_hash[coord1] == coordinate_with_piece_hash[coord2]) && (coordinate_with_piece_hash[coord1] == coordinate_with_piece_hash[coord3]) # If coord1's piece, matches coord2's piece, and also coord3's piece, then they are all the same.
  
      if (coordinate_with_piece_hash[coord1] != nil)  # We have to make sure that the 3 matches are not "nil" matches, since this check runs after each board piece placed, and in the beginning, there will be alot of 3 in a row nil matches.
        return true # If there is a 3 in a row match, return true.
      end
    end
  
  end

  def self.game_over? (coordinate_with_piece_hash) # This method checks to see if the game is over, by running the "check_for_winner" function for each winning combo, that is, top row, mid row, bot row, left column, mid column, right column, right to left diagonal, and left to right diagonal, respectively.
    if (Game.check_for_winner([0,0], [0,1], [0,2], coordinate_with_piece_hash) == true || Game.check_for_winner([1,0], [1,1], [1,2], coordinate_with_piece_hash) == true || Game.check_for_winner([2,0], [2,1], [2,2], coordinate_with_piece_hash) == true || Game.check_for_winner([0,0], [1,0], [2,0], coordinate_with_piece_hash) == true || Game.check_for_winner([0,1], [1,1], [2,1], coordinate_with_piece_hash) == true || Game.check_for_winner([0,2], [1,2], [2,2], coordinate_with_piece_hash) == true || Game.check_for_winner([2,2],[1,1],[0,0], coordinate_with_piece_hash) == true || Game.check_for_winner([2,0], [1,1], [0,2], coordinate_with_piece_hash) == true) 
      return true # If any of those 3 in a row combos exist, then return true that the game is over.
    else
      return false # Otherwise return false.
    end

  end

  def self.computer_pick (available_coordinates_array) # This function let's the computer randomly pick a converted coordinate from the available coordinates array.

    computer_picked_coordinate = available_coordinates_array.sample # We get a random element from our array with the "sample" method, and set it equal to "computer_picked_coordinate", which we will return.
    return computer_picked_coordinate
  end

end

class Player # The player class creates players with name and piece properties.

  attr_accessor :name # "attr_accessor" for name and piece allows those properties to be called as methods by Person class objects, such as player1 and player2.
  attr_accessor :piece

  def initialize (name, piece) # We initialize with name and piece parameters.
    @name = name
    @piece = piece
  end

end

game = Game.new # Outside of our classes, we create a "game" object to call the "play" method.
game.play # Then run the play function to start the game.

























