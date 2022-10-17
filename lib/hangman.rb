# frozen_string_literal: false

require 'csv'
require 'json'

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
  attr_accessor :tiles, :letter_str, :stick_array, :display

  def initialize(word)
    @word = word
    @word_count = @word.length
    @display = ' ' * 15 + ('%1c ' * @word_count)
    @tiles = Array.new(1) { Array.new(@word_count) { '_' } }
    @stick_array = [' '] * 6
    @letter_str = ''
    display_game
  end

  def stickman_display
    puts "\e[H\e[2J"
    puts ' ' * 18 + 'Hangman!'
    puts "
               |----------                Enter 1 to save your game
               |         |                Enter 2 to load your game
               |         #{@stick_array[0]}
               |       #{@stick_array[3]}#{@stick_array[1]}#{@stick_array[2]}
               |        #{@stick_array[4]} #{@stick_array[5]}
               |\__
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
    puts 'Incorrect guesses: ' + " [  #{@letter_str}  ]
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
  attr_accessor :letter, :word, :correct_count, :word_list

  @@incorrect_count = 0

  def initialize
    @used_letter = []
    @correct_count = 0
    @word_list = Dictionary.new
    @word = random_word_gen(@word_list.load_dictionary).downcase # Generate random word from dictionary
    load_or_new_game
  end

  def play_game
    @game = Graphics.new(@word)
    if @old_game == true
      load_game
      @game.display_game
      @old_game = false
    end
    game_loop
  end

  def game_loop
    until @guess_correctly == true || @@incorrect_count == 5
      take_player_guess
      check_for_win
    end
    game_over
  end

  def load_or_new_game
    puts '
    [1] New Game
    [2] Load Game'
    @input = gets.chomp.to_s
    case @input
    when '1'
      play_game
    when '2'
      @old_game = true
      play_game
    else
      puts 'Please enter 1 or 2'
      @input = gets.chomp.to_s
    end
  end

  def take_player_guess
    puts 'Take a guess...'
    @next_input = false

    @letter_input = gets.chomp.to_s.downcase
    check_for_game_save
    return if @next_input == true

    check_letter
    register_letter(@letter_input)
  end

  def check_for_game_save
    case @letter_input
    when '1'
      save_game
      @next_input = true
    when '2'
      load_game
      @game.display_game
      @next_input = true
    end
  end

  # Player option to save the game in its current state
  def save_game
    Dir.mkdir('save_files') unless Dir.exist?('save_files')
    filename = 'save_files/save.json'

    File.open(filename, 'w') do |file|
      file.puts JSON.pretty_generate({ tiles: @game.tiles.to_json,
                                       stick_array: @game.stick_array.to_json,
                                       letter_array: @game.letter_str.to_json,
                                       display: @game.display.to_json,
                                       incorrect_count: @@incorrect_count.to_json,
                                       used_letter: @used_letter.to_json,
                                       correct_count: @correct_count.to_json, 
                                       word: @word.to_json })
    end
    puts 'Saving game...'
    $stdout.flush
    sleep(2)
    @game.display_game
  end

  def load_game
    file = File.read('save_files/save.json')
    save_hash = JSON.parse(file, { symbolize_names: true })

    @game.tiles = JSON.parse(save_hash[:tiles])
    @game.stick_array = JSON.parse(save_hash[:stick_array])
    @game.letter_str = JSON.parse(save_hash[:letter_array])
    @game.display = JSON.parse(save_hash[:display])
    @@incorrect_count = save_hash[:incorrect_count].to_i
    @used_letter = JSON.parse(save_hash[:used_letter])
    @correct_count = save_hash[:correct_count].to_i
    @word = JSON.parse(save_hash[:word])
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
