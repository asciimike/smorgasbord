class StateMachine:
	def __init__(self,numStates):
		self.state = 0
		self.numStates = numStates
	def __repr__(self):
		print 'State ' + str(self.state)
	def incrementMachine(self):
		self.state = self.state + 1
		if self.state >= self.numStates:
			self.state = 0