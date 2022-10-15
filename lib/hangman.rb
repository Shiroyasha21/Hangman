require 'csv'

# Generate random word
module WordGenerator
  def random_word_gen(dictionary)
    new_dictionary = []
    dictionary.each do |word|
      if word.length > 4 && word.length < 16
        new_dictionary.push(word)
      end
    end
    new_dictionary.sample
  end
end

# Creates dictionary
class Dictionary
  attr_accessor :dictionary

  CONTENT = CSV.open('dictionary.csv')

  def load_dictionary
    @dictionary = []
    CONTENT.each do |word|
      word = word[0]
      dictionary.push(word)
    end
    @dictionary
  end
end

# Create the placeholder for the word, the letter count, and guessed remaining
class Graphics
  attr_accessor :tiles

  def initialize(word)
    @word = word
    @word_count = @word.length
    @display = 'Guess: ' + ' ' * 8 + ('%1c ' * @word_count)
    @tiles = Array.new(1) { Array.new(@word_count) { '_' } }
    @stick_array = [''] * 6
    @letter_str = ''
    display_game
  end

  def stickman_display
    puts "\e[H\e[2J"
    puts ' ' * 18 + 'Hangman!'
    puts "
               |----------
               |         |
               |         #{@stick_array[0]}
               |       #{@stick_array[3]}#{@stick_array[1]}#{@stick_array[2]}
               |        #{@stick_array[4]} #{@stick_array[5]}
               |
               "
  end

  def display_game
    stickman_display
    @tiles.each_with_index do |elem, _index|
      puts ''
      puts(@display % elem)
    end
    puts ''
    guessed_letters('')
  end

  def stickman_progress(incorrect_count)
    case incorrect_count
    when 1
      @stick_array[0] = '0'
    when 3
      @stick_array[1] = 'I'
    when 2
      @stick_array[2] = '-*'
      @stick_array[3] = '*-'
    when 4
      @stick_array[4] = '/'
    when 5
      @stick_array[5] = '\\'
    end
    display_game
  end

  def guessed_letters(incorrect_letter)
    @letter_str.concat(incorrect_letter)
    puts ' ' * 12 + " #{@letter_str}
    "
  end

  def change_placeholder_display(correct_letter, index)
    @tiles.map! do |row|
      row.each_with_index do |_char, tile_index|
        if index == tile_index
          row[tile_index] = correct_letter
        end
      end
    end
    display_game
  end

  def hanging_the_stick(incorrect_letter, incorrect_count)
    guessed_letters(incorrect_letter)
    stickman_progress(incorrect_count)
  end
end

# Start the game
class Hangman
  include WordGenerator
  attr_accessor :letter, :word, :correct_count

  @@incorrect_count = 0

  def initialize
    @used_letter = []
    @correct_count = 0
    @word_list = Dictionary.new
    @word = random_word_gen(@word_list.load_dictionary).downcase # Generate random word from dictionary
    @game = Graphics.new(@word) # Place the word to the placeholder
    play_game
  end

  def play_game
    until @guess_correctly == true || @@incorrect_count == 5
      take_player_guess
      check_for_win
    end
    game_over
  end

  def take_player_guess
    puts "Take a guess..."

    @letter_input = gets.chomp.to_s.downcase
    check_letter

    register_letter(@letter_input)
  end

  def check_letter
    while @used_letter.any?(@letter_input) || @letter_input.match?(/\d+/) || @letter_input.length > 1
      puts 'Invalid guess. Try again'
      @letter_input = gets.chomp.to_s
    end
  end

  def register_letter(letter_guessed)
    @used_letter << letter_guessed
    if @word.include? letter_guessed
      check_char_index(letter_guessed)
    else
      hang_the_stick(letter_guessed)
    end
  end

  def check_char_index(letter)
    @char_hash = {}
    @word.each_char.with_index do |char, index|
      if letter == char
        @char_hash[index] = char
      end
    end
    @char_hash.each_pair {|index, char|
      @game.change_placeholder_display(char, index)
      @correct_count += 1
    }
  end

  def hang_the_stick(letter)
    @@incorrect_count += 1

    @game.hanging_the_stick(letter, @@incorrect_count)
    puts 'Incorrect guess!
    '
  end

  # Game check
  def check_for_win
    if @correct_count == @word.length
      @guess_correctly = true
    else
      false
    end
  end

  def game_over
    if @guess_correctly == true
      puts 'You guessed the word correctly! You win!'
    else
      show_word
    end
  end

  def show_word
    @word.each_char.with_index do |word_char, word_index|
      @game.change_placeholder_display(word_char, word_index)
    end
    puts 'The stickman is dead. Game over!'
  end
end

Hangman.new
# For each letter used by player, it goes through the word array
# If guessed correctly, replace placeholder with corresponding letter from array
# Iterate letter count and guesses remaining

# Player lose if used all the number of guess
# Player win if guessed all the letters of the word correctly

# Player option to save the game in its current state
