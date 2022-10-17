Project: Hangman

This project comes from the Ruby Course of The Odin Project's curriculum. The project showcase how to serialize objects and classes using different serialization format, which in this case is JSON. 

I wrote this program after a five month break which caused hardship and confusion throughout writing the program. 


How the game works:
  At the start of the game, player would choose whether to start a new game or load a saved state of the game.
  
  Player would then guess a letter from the word. If correct, it would show the letter of the word, and if not, it would show in the 'Incorrect guesses' box of letters.

  Player wins the game if guessed correctly all the words, otherwise it would hang the poor stickman after incorrectly guessing five times.


Missing functionality:
  After the player win or lose, it would exit the game after showing the victory/lose screen. A choice to play the game again or exit was written but I wasn't able to figure out why a new instance of the game continue to use old variables, and variables would become nil after a new instance. For example, running play_again that creates a new 'Hangman.new' results in no method error for the '@word' variable because of it having a nil value.

  The save function can only save one instance of the game state. It would rewrite the save file if the player choose to save the game. Due to a long time taken to write the game, I choose to write a simple save functionality, rather than letting the player make his own save file, and select which save to load.

Known problems:
  Even though the player cannot enter digit characters except 1 and 2, I wasn't able to catch non-alpha numeric characters such as colon and commas.

