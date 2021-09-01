

"""#

Write a function called `guessing_game` that satisfies the following requirements:

1.  When the function is called, the user is prompted to guess a word
1.  The function, internally, will randomly choose a word for the game.  The population of word (the word list) is shown below.
1.  If the user does not guess the proper word, the user should be prompted again to try another guess
1.  The user is only allowed 3 guesses.  If the user fails to guess the chosen word after 3 attempts, the message `Sorry, the game is over.` should be printed to the screen.
1.  If the user enters a word not part of the list below, the message `That word is not part of the vocabulary.` should be printed to the screen.  However, if this situation occurs during the 3rd failed guess, only the message in step 4 should be printed.
1.  If the user correctly guesses the word, the message `Correct! Well Done.` should be printed on the screen.
1.  If a string is not input by the user, the function should print `You did not guess a string, Game Over!` and end the game. You can use `string` package as in `string.ascii_letters` to guarantee that the entry is a string semantically.



The word list that should be used by the function:

- `numpy`
- `seaborn`
- `pandas`
- `pantab`
- `spacy`
- `requests`
- `tensorflow`


"""

import random
import string
valid_characters = string.ascii_letters
words = ["numpy", "seaborn", "pandas","pantab","spacy","requests","tensorflow"]
random_word = random.choice(words)
def guessing_game():
  guesses = 0
  while guesses < 3:
    guess = input("Guess a word:")
    for char in guess:
      if char not in valid_characters:
        print("You did not guess a string, Game Over!")
        return
      if guess not in words and guesses < 2:
        print("That word is not part of the vocabulary.")
        guesses += 1
        break
      if guess not in random_word:
        guesses += 1
        break;
      else:
        print("Correct! Well Done.")
        return
  else:
    print("Sorry, the game is over.")

guessing_game()

mylist = [1,2,3,4]
for i in mylist:
  if i == 2:
    break
  print("done with iteration")
