require 'csv'

# Loads the Dictionary and generate a random word
module Dictionary
  def random_word_gen(dictionary)
    new_dictionary = []
    dictionary.each do |word|
      if word.length > 4 && word.length < 13
        new_dictionary.push(word)
      end
    end
    new_dictionary.sample
  end

  contents = CSV.open('dictionary.csv')
  dictionary = []
  contents.each do |word|
    word = word[0]
    dictionary.push(word)
  end
end

# Create the placeholder for the word, the letter count, and guessed remaining
class Graphics

  def initialize(word)
    @word = word
    @word_count = @word.length
    @display = 'Guess: ' + ' ' * 13 + ('%1c ' * @word_count)
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

  def stickman_progress(guess_count)
    case guess_count
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

  def guessed_letters(letter)
    @letter_str.concat(letter)
    puts ' ' * 12 + " #{@letter_str}
    "
  end
end

new = Graphics.new('What')

# Start the game
class Hangman
  include Dictionary
  attr_accessor :letter, :word

  def initialize
    @letter = letter
    @word = random_word_gen
    @game = Graphics.new(@word)

# Generate random word from dictionary
# Place the word to the placeholder

# Let player guess
# For each letter used by player, it goes through the word array
# If guessed correctly, replace placeholder with corresponding letter from array
# Iterate letter count and guesses remaining

# Player lose if used all the number of guess
# Player win if guessed all the letters of the word correctly

# Player option to save the game in its current state
