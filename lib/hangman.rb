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
      row.each_with_index do |char, tile_index|
        if index == tile_index
          row[tile_index] = correct_letter
        end
      end
    end
    display_game
  end

  def hanging_the_stick(incorrect_letter, incorrect_count)

end

# Start the game
class Hangman
  include Dictionary
  attr_accessor :letter, :word

  @incorrect_count = 0

  def initialize
    @letter = letter
    @used_letter = []
    @word = random_word_gen.downcase # Generate random word from dictionary
    @game = Graphics.new(@word) # Place the word to the placeholder
    play_game
  end

  def play_game
    until guess_correctly == true || incorrect_count == 5
      take_player_guess
      check_for_win
      check_for_gameover
    end
  end

  def take_player_guess
    puts 'Take a guess...'

    @letter_input = gets.chomp.to_s
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
    dupe_counter = 0
    @word.each_char.with_index do |char, index|
      if letter == char
        @char_hash[index] = char
        ++dupe_counter
      end
    end
    if dupe_counter == 1
      single_char_register
    else
      multi_char_register
    end
  end
end

# For each letter used by player, it goes through the word array
# If guessed correctly, replace placeholder with corresponding letter from array
# Iterate letter count and guesses remaining

# Player lose if used all the number of guess
# Player win if guessed all the letters of the word correctly

# Player option to save the game in its current state
