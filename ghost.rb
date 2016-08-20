# implementation of Ghost (text/word game) played on the console.
# Details can be found here: https://en.wikipedia.org/wiki/Ghost_(game)

require "set"

class Ghost
  attr_reader :players, :dictionary, :fragment, :losses

  ALPHABET = ("a".."z").to_a
  MAX_LOSSES = 5

  def initialize(*players)
    @players = players
    @dictionary = Set.new(File.readlines("dictionary.txt").map(&:chomp))
    @losses = Hash.new()

    players.each { |player| losses[player] = 0 }
  end

  def play_round
    @fragment = ""
    puts "Let's play!"
    until round_over?
      render
      take_turn(current_player)
      next_player!
    end
      puts "Opps! #{fragment} is a word! #{previous_player} loses!"
      losses[previous_player] += 1
  end

  def run
    puts "WELCOME TO GHOST"
    until losses.any? { |player, losses| losses == MAX_LOSSES }
      play_round
      display_standings
    end
    puts "GAME OVER!"
    puts "#{current_player} wins!! Hooray for #{current_player}!!"
  end

  def current_player
    players.first
  end

  def previous_player
    players.last
  end

  def next_player!
    players.rotate!
  end

  def take_turn(player)
    letter = nil
    until valid_play?(letter)
      letter = player.guess
    end
    fragment << letter
  end

  def valid_play?(letter)
    return false unless ALPHABET.include?(letter)
    guess = fragment + letter
    candidate_length = guess.length + 1
    candidate_words = @dictionary.select { |word| word.length > candidate_length }
    return true if candidate_words.any? { |word| word.start_with?(guess) }
  end

  def round_over?
      return true if @dictionary.include?(fragment) && fragment.length >= 3
  end

  def render
    puts "\n"
    puts "The current string is ...#{fragment}."
    puts "\n"
    puts "It is #{current_player} turn!!"
    puts "Enter a letter."
    sleep 1
  end

  def record(player)
    "GHOST"[0...losses[player]]
  end

  def display_standings
    puts "\n"
    puts "***************************"
    puts "The current standings are:"
    players.each do |player|
      puts "#{player} has current score of #{record(player)}."
    end
    puts "***************************"
    puts "\n"
  end

end

class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def guess
    letter = gets.chomp
  end

  def to_s
    name
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Ghost.new(Player.new("Stimps"), Player.new("Ox"))
  game.run
end
