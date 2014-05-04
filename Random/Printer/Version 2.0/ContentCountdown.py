from datetime import datetime
from pytz import timezone

# This class uses imperial units for all values

class ContentCountdown:
	def __init__(self, day, month, year, hour, minute):
		dt = datetime.datetime
		self.daysLeft = 0
		self.hoursLeft = 0
		self.minutesLeft = 0
		self.date = dt(year, month, day, hour, minute)

	def __repr__(self):
		return str(self.daysLeft) + ' Days left\n' + str(self.hoursLeft) + ' Hours left\n' + str(self.minutesLeft) + ' Minutes left\n' + str(self.secondsLeft) + ' Seconds left'

	# TODO: clean up some of the cludge code here... especially for lengths
	def getContent(self):
		line0 = 'GRADUATION COUNTDOWN'
		line1 = '    Days: ' + str(self.daysLeft)
		line1 = ((11 - len(line1))/2)*' ' + line1 + ((11 - len(line1))/2)*' '
		while (len(line1) < 20):
			line1 += ' '
		line2 = '    Hours: ' + str(self.hoursLeft)
		line2 = ((10 - len(line2))/2)*' ' + line2 + ((10 - len(line2))/2)*' '
		while (len(line2) < 20):
			line2 += ' '
		line3 = '    Minutes: ' + str(self.minutesLeft)
		line3 = ((8 - len(line3))/2)*' ' + line3 + ((8 - len(line3))/2)*' '
		while (len(line3) < 20):
			line3 += ' '
		return line0 + line1 + line2 + line3

	def updateContent(self):
		dt = datetime
		now = dt.now(tz=timezone('US/Eastern'))
		delta = self.date - dt(year = now.year, month = now.month, day = now.day, hour = now.hour, minute = now.minute)
		self.daysLeft = delta.days
		self.hoursLeft = delta.seconds/3600
		self.minutesLeft = (delta.seconds - (3600*self.hoursLeft))/60