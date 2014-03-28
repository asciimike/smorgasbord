#Abstract content class
class Content:
	def __init__(self):
		raise NotImplementedError("Init not defined for base class, please implement")

	def __repr__(self):
		raise NotImplementedError("Repr not defined for base class, please implement")

	def updateContent(self):
		raise NotImplementedError("Update not defined for base class, please implement")

	def getContent(self):
		raise NotImplementedError("Get not defined for base class, please implement")