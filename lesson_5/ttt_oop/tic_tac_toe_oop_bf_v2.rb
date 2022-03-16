module Displayable
  def display_welcome_message
    puts "Welcome to Tic Tack Toe!"
    puts "Before we start we need to set the game up ..."
    sleep(2)
  end

  def display_setup_summary
    clear
    puts "Great! We're good to go! Let's sum up ..."
    puts ""
    puts "You have '#{human.marker}' marker, #{computer.name} " \
      "has a '#{computer.marker}'."
    puts "We are playing to #{TTTGame::WINNING_SCORE} wins."
    puts "#{first_to_move_name} will take the first move."
    puts "Good luck!"
  end

  def display_board
    display_score
    puts "You're a #{human.marker}. #{computer.name} is #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_score
    puts "Score: #{human.name} - #{human.score}  #{computer.name} -" \
      " #{computer.score}"
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_game_winner
    if game_winner == human.marker
      puts "#{human.name} won the game!"
    elsif game_winner == computer.marker
      puts "#{computer.name} won the game!"
    end
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_goodbye_message
    puts TTTGame::DIVIDER
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_marker(key)
    if @squares[key].unmarked?
      '[' + @squares[key].marker + ']'
    else
      ' ' + @squares[key].marker + ' '
    end
  end
end

module UserInteractable
  VALID_YES_NO = ['y', 'n']
  VALID_PLAYER_COMPUTER = ['p', 'c']

  def retrieve_human_name
    name = ""
    loop do
      puts "What's your name?"
      name = gets.chomp
      break unless name.delete(' ').empty?
      puts "Sorry, must enter a value."
    end
    name
  end

  def retrieve_computer_name
    name = ""
    loop do
      puts "What's computer name?"
      name = gets.chomp
      break unless name.delete(' ').empty?
      puts "Sorry, must enter a value."
    end
    name
  end

  def retrieve_human_marker
    answer = nil
    loop do
      puts "Please choose marker you would like to use (must be one" \
           " character long, no digits allowed):"
      answer = gets.chomp
      break if answer.delete(' ').size == 1 && !(('0'..'9').include?(answer))
      puts "Sorry, that's not a valid choice."
    end
    answer
  end

  def decide_who_goes_first?
    answer = nil
    loop do
      puts "Do you want to decide who makes first move? (y or n)"
      answer = gets.chomp.downcase
      break if VALID_YES_NO.include?(answer)
      puts "Input seems to be incorrect. Choose 'y' if you want to decide " \
           "who makes first move,\n'n' otherwise."
    end
    answer == 'y'
  end

  def retrieve_who_goes_first_choice
    answer = nil
    loop do
      puts "Who should start first? (P)layer or (C)omputer?"
      answer = gets.chomp.downcase
      break if VALID_PLAYER_COMPUTER.include?(answer)
      puts "Input seems to be incorrect. Choose 'p' for player, " \
           "'c' for computer."
    end
    answer
  end

  def continue_to_first_round
    puts TTTGame::DIVIDER
    puts "Press Enter to continue to the first round."
    gets
    clear
  end

  def continue_to_next_round
    puts TTTGame::DIVIDER
    if game_end?
      display_game_winner
    else
      puts "Press Enter to continue to the next round."
      gets
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if VALID_YES_NO.include?(answer)
      puts "Sorry, must be y or n"
    end
    answer == 'y'
  end
end

class Board
  include Displayable

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def markers_equal?(squares)
    markers = squares.collect(&:marker)
    markers.size == markers.count do |marker|
      markers[0] == marker
    end
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares_in_line = @squares.values_at(*line)
      return squares_in_line[0].marker if markers_equal?(squares_in_line)
    end
    nil
  end

  def someone_won?
    !!winning_marker
  end

  def opportunity_key(player_marker)
    WINNING_LINES.each do |line|
      markers_in_line = @squares.values_at(*line).map(&:marker)
      if markers_in_line.count(player_marker) == 2 &&
         unmarked_count(markers_in_line) == 1
        line.each do |key|
          return key if @squares[key].unmarked?
        end
      end
    end
    nil
  end

  def unmarked_count(markers_arr)
    markers_arr.select { |m| m == m.to_i.to_s }.size
  end

  def win_opportunity?(player_marker)
    !!opportunity_key(player_marker)
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new(key) }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts " #{display_marker(1)} | #{display_marker(2)} | #{display_marker(3)}"
    puts "     |     |"
    puts "-----|-----|-----"
    puts "     |     |"
    puts " #{display_marker(4)} | #{display_marker(5)} | #{display_marker(6)}"
    puts "     |     |"
    puts "-----|-----|-----"
    puts "     |     |"
    puts " #{display_marker(7)} | #{display_marker(8)} | #{display_marker(9)}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end

class Square
  attr_accessor :marker

  def initialize(marker)
    @marker = marker.to_s
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == marker.to_i.to_s
  end
end

class Player
  attr_accessor :score, :marker, :name

  def initialize
    @marker = nil
    @score = 0
    @name = nil
  end
end

class Human < Player
  def moves(board)
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = marker
  end

  def joinor(keys, delimiter = ', ', word = 'or')
    case keys.size
    when 0 then ''
    when 1 then keys.first.to_s
    when 2 then keys.join(' ' + word + ' ')
    else
      keys[0..(keys.size - 2)].join(delimiter) + delimiter +
        word + ' ' + keys.last.to_s
    end
  end
end

class Computer < Player
  def moves(board, human_marker)
    if board.win_opportunity?(marker)
      mark_opportunity_square(board, marker, marker)
    elsif board.win_opportunity?(human_marker)
      mark_opportunity_square(board, human_marker, marker)
    elsif board.unmarked_keys.include?(5)
      board[5] = marker
    else
      computer_marks_random_square(board)
    end
  end

  def mark_opportunity_square(board, opportunity_marker, player_marker)
    board[board.opportunity_key(opportunity_marker)] = player_marker
  end

  def computer_marks_random_square(board)
    board[board.unmarked_keys.sample] = marker
  end
end

class TTTGame
  include Displayable
  include UserInteractable

  WINNING_SCORE = 2
  DIVIDER = "-" * 42

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @first_to_move = nil
    @current_player = nil
  end

  def play
    clear
    display_welcome_message
    game_setup
    main_game
    display_goodbye_message
  end

  private

  def clear
    system 'clear'
  end

  def game_setup
    set_names
    set_markers
    who_goes_first
    display_setup_summary
    continue_to_first_round
  end

  def set_names
    human.name = retrieve_human_name
    computer.name = retrieve_computer_name
  end

  def set_markers
    human.marker = retrieve_human_marker
    computer.marker =
      ['Q', 'D', 'o', 'O', '0'].include?(human.marker) ? 'X' : 'O'
  end

  def who_goes_first
    if decide_who_goes_first?
      choice = retrieve_who_goes_first_choice
      @first_to_move = choice == 'p' ? human.marker : computer.marker
    else
      @first_to_move = [human.marker, computer.marker].sample
    end
    @current_player = @first_to_move
  end

  def first_to_move_name
    if @first_to_move == human.marker
      human.name
    elsif @first_to_move == computer.marker
      computer.name
    end
  end

  def main_game
    loop do
      play_round
      break unless play_again?
      reset_game
      display_play_again_message
    end
  end

  def play_round
    loop do
      display_board
      player_move
      display_result
      update_score
      display_score
      continue_to_next_round
      break if game_end?
      reset_round
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def human_turn?
    @current_player == human.marker
  end

  def current_player_moves
    case @current_player
    when human.marker
      human.moves(board)
      @current_player = computer.marker
    when computer.marker
      computer.moves(board, human.marker)
      @current_player = human.marker
    end
  end

  def update_score
    if board.winning_marker == human.marker
      human.score += 1
    elsif board.winning_marker == computer.marker
      computer.score += 1
    end
  end

  def game_winner
    if human.score == WINNING_SCORE
      human.marker
    elsif computer.score == WINNING_SCORE
      computer.marker
    end
  end

  def game_end?
    !!game_winner
  end

  def reset_round
    board.reset
    @current_player = @first_to_move
    clear
  end

  def reset_game
    reset_round
    human.score = 0
    computer.score = 0
  end
end

game = TTTGame.new
game.play
