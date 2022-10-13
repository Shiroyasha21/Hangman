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
  attr_accessor :word, :letter_count, :num_guesses

  def initialize(word)
    @word = word
    @word_count = @word.length
    @display = '%1c ' * @word_count
    @tiles = Array.new(1) { Array.new(@word_count) { '_' } }
    display_placeholder
  end

  def display_placeholder
    puts "\e[H\e[2J"
    @tiles.each_with_index do |elem, _index|
      puts(@display % elem)
    end
  end
end

Graphics.new('About')

# Start the game
# Generate random word from dictionary
# Place the word to the placeholder

# Let player guess
# For each letter used by player, it goes through the word array
# If guessed correctly, replace placeholder with corresponding letter from array
# Iterate letter count and guesses remaining

# Player lose if used all the number of guess
# Player win if guessed all the letters of the word correctly

# Player option to save the game in its current state
