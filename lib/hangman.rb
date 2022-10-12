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

