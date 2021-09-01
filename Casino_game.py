import random
import numpy as np


class dice_game:
	""" Welcome to Casino Royale"""
	def __init__(self, players : int = 50, wallet = [], games_played = []):
		self.players = players
		self.wallet = wallet
		self.games_played = games_played

#simulate which will simulate a session at the table for a number of players. The number of players is defined by players attribute described above.

	def simulate(self):
		""" For this method we will simulate a session at the table for a number of players"""
		#beginning_credits = 10
		#credits = 0
		#rounds = 1
		#while rounds < 25 and credits


		for player in range(self.players):
			
			rounds = 0
			credits = 10
			while rounds < 25 and credits > 0:

				
				

				dice1 = random.randint(1,6)
				#print(dice1)
				dice2 = random.randint(1,6)
				#print(dice2)
				grand_total = dice1 + dice2

				if grand_total <= 9:
					dice3 = random.randint(1,6)
					#print(dice3)
					grand_total += dice3
					if grand_total <= 9:
						credits +=  0
					elif grand_total == 10 or grand_total == 12:
						credits += 1
					elif grand_total == 13:
						credits += 2
					elif grand_total == 11 or grand_total == 14 or grand_total == 15:
						credits += 0
					elif grand_total == 16:
						credits += 5


				elif grand_total == 10:
					roll_decision = ["roll","stay"]
					distribution = [.9,.1]
					random_decision = random.choices(roll_decision, distribution)
					if random_decision == "roll":
						dice3 = random.randint(1,6)
						#print(dice3)
						grand_total = grand_total + dice3
						if grand_total == 12:
							credits += 1
						elif grand_total == 13:
							credits += 2
						elif grand_total == 11 or grand_total == 14 or grand_total == 15:
							credits += 0
						elif grand_total == 16:
							credits += 5
					else:
						grand_total = grand_total
						credits += 1
						

				elif grand_total > 10:
					if grand_total == 12:
							credits += 1
					elif grand_total == 13:
							credits += 2
					elif grand_total == 11 or grand_total == 14 or grand_total == 15:
							credits += 0
					elif grand_total == 16:
							credits += 5


				
				credits = credits - 1
				rounds += 1

			
			self.wallet.append(credits)
			self.games_played.append(rounds)

				

			#print("Grand total " +  str(grand_total)) 
			#print("End Credits " + str(credits))
			#print("Rounds " + str(rounds))

#avg_rounds which will return an integer indicating the average rounds at the table for all players
	def avg_rounds(self):
		"""This method will return an integer indicating the average rounds at the table for all players"""

		return (int(sum(self.games_played)/len(self.games_played)))

#profit which will return an integer indicating the net number of credits the Casino can expect to make or lose across the simulation of the game for all players
	def profit(self):
		"""This method will return an integer indicating the net number of credits the Casino can expect to make or lose across the simulation of the game for all players"""

		wallet_array = np.array(self.wallet)
		profits = int(np.sum(10-wallet_array))

		if profits > 0:
			print("Casino made a profit of ${}".format(profits))
		elif profits < 0:
			print("Casino made a loss of ${}".format(profits))
		return (profits)



dice = dice_game()

#dice.simulate()
#print(dice.players)
print(len(dice.wallet))
#print(len(dice.games_played))

#print(dice.games_played)
#print(dice.avg_rounds())
#print(dice.profit())

