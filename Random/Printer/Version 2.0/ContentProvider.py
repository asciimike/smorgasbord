class ContentProvider:
	def __init__(self,contentToDisplay):
		self.state = 0
		self.content = contentToDisplay

	def __repr__(self):
		print 'State ' + str(self.state)

	def getNextContent(self):
		self.state = self.state + 1
		if self.state >= len(self.content):
			self.state = 0
		return self.content[self.state]
