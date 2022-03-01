YES_NO = ['y', 'n']
VALID_CHOICE_INPUT = ['rock', 'paper', 'scissors', 'spock', 'lizard',
                      'r', 'p', 'sc', 'sp', 'l']

class Score
  WIN_SCORE = 3
  attr_accessor :value

  def initialize
    @value = 0
  end

  def reset
    @value = 0
  end
end

class Move
  attr_reader :value, :choice

  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

  def initialize(choice)
    @choice =
      case choice
      when 'rock', 'r'      then Rock.new
      when 'paper', 'p'     then Paper.new
      when 'scissors', 'sc' then Scissors.new
      when 'spock', 'sp'    then Spock.new
      when 'lizard', 'l'    then Lizard.new
      end
  end

  def >(other_choice)
    @win_against.include?(other_choice.value)
  end

  def <(other_choice)
    @lose_against.include?(other_choice.value)
  end

  def to_s
    @value
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
    @win_against = ['scissors', 'lizard']
    @lose_against = ['paper', 'spock']
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
    @win_against = ['rock', 'spock']
    @lose_against = ['scissors', 'lizard']
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @win_against = ['paper', 'lizard']
    @lose_against = ['rock', 'spock']
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @win_against = ['rock', 'scissors']
    @lose_against = ['paper', 'lizard']
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @win_against = ['paper', 'spock']
    @lose_against = ['rock', 'scissors']
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = Score.new
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose [r]ock, [p]aper, [sc]issors, [sp]ock or [l]izard."
      choice = gets.chomp.downcase
      break if VALID_CHOICE_INPUT.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  attr_reader :robot

  def initialize
    @robot = [Chappie.new, R2D2.new, Hal.new].sample
    super
  end

  def set_name
    self.name = robot.name
  end

  def choose
    self.move = Move.new(robot.choice)
  end
end

class R2D2 < Computer
  def initialize
    @name = 'R2D2'
  end

  def choice
    'rock'
  end
end

class Hal < Computer
  def initialize
    @name = 'Hal'
  end

  def choice
    roll = rand(10)
    case roll
    when 0..4 then 'scissors'
    when 5    then 'rock'
    when 6, 7 then 'spock'
    when 8, 9 then 'lizard'
    end
  end
end

class Chappie < Computer
  def initialize
    @name = 'Chappie'
  end

  def choice
    Move::VALUES.sample
  end
end

class Record
  def initialize(round_number, human, computer)
    @round_number = round_number
    @human_move = human.move.choice.value
    @computer_move = computer.move.choice.value
    @human_score = human.score.value
    @comuter_score = computer.score.value
    @human_name = human.name
    @computer_name = computer.name
  end

  def to_s
    "Round #{@round_number}: Score #{@human_score} - #{@comuter_score}. " \
      "#{@human_name} chose #{@human_move}, " \
      "#{@computer_name} chose #{@computer_move}."
  end
end

class History
  attr_accessor :records

  def initialize
    @records = {}
  end

  def add_record(game_number, round_number, human, computer)
    if records.key?(game_number)
      records[game_number] << Record.new(round_number, human, computer)
    else
      records[game_number] = [Record.new(round_number, human, computer)]
    end
  end

  def display
    puts "======== Game History ========"
    records.each do |game_number, game_records|
      puts "Game #{game_number}"
      game_records.each do |game_record|
        puts game_record
      end
      puts "------------------------------"
    end
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer
  attr_reader :history

  def initialize
    @human = Human.new
    @computer = Computer.new
    @history = History.new
  end

  def display_welcome_message
    system('clear')
    puts <<~MS
      Welcome to Rock, Paper, Scissors, Spock, Lizard!,
        Game is played to #{Score::WIN_SCORE} wins.
      
        You can use shortcuts for typing your choice:
        For rock type 'r' or 'rock',
        paper: 'p' or 'paper',
        scissors: 'sc' or 'scissors',
        spock: 'sp' or 'spock',
        lizard: 'l' or 'lizard'.
    MS
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move.choice}."
    puts "#{computer.name} chose #{computer.move.choice}."
  end

  def display_round_winner
    human_choice = human.move.choice
    computer_choice = computer.move.choice

    if human_choice > computer_choice
      puts "#{human.name} scores!"
    elsif human_choice < computer_choice
      puts "#{computer.name} scores!"
    else
      puts "It's a tie"
    end
  end

  def update_score
    human_choice = human.move.choice
    computer_choice = computer.move.choice

    human.score.value += 1 if human_choice > computer_choice
    computer.score.value += 1 if human_choice < computer_choice
  end

  def display_score
    puts "Score: #{human.name} - #{human.score.value}  " \
         "#{computer.name} - #{computer.score.value}"
    puts "--------------------------"
  end

  def display_game_winner
    if human.score.value == Score::WIN_SCORE
      puts "#{human.name} won the game!"
    elsif computer.score.value == Score::WIN_SCORE
      puts "#{computer.name} won the game!"
    end
    puts "=========================="
  end

  def play_again?
    answer = nil
    loop do
      puts "Do you want to play again? (y/n)"
      answer = gets.chomp.downcase
      break if YES_NO.include?(answer)
      puts "Sorry must be 'y' or 'n'"
    end
    answer == 'y'
  end

  def display_history
    system('clear')
    answer = nil
    loop do
      puts "Do you want to see history of the game?"
      answer = gets.chomp
      break if YES_NO.include?(answer.downcase)
      puts "Sorry must be 'y' or 'n'"
    end
    history.display if answer.downcase == 'y'
  end

  def win?
    human.score.value == Score::WIN_SCORE ||
      computer.score.value == Score::WIN_SCORE
  end

  def play_round(game_number, round_number)
    human.choose
    computer.choose
    display_moves
    display_round_winner
    update_score
    display_score
    history.add_record(game_number, round_number, human, computer)
  end

  def reset_scores
    human.score.reset
    computer.score.reset
  end

  def play_game(game_number)
    round_number = 1
    loop do
      play_round(game_number, round_number)
      if win?
        display_game_winner
        reset_scores
        break
      end
      round_number += 1
    end
  end

  def play
    display_welcome_message

    game_number = 1
    loop do
      play_game(game_number)
      break unless play_again?
      system('clear')
      game_number += 1
    end

    display_history
    display_goodbye_message
  end
end

RPSGame.new.play
