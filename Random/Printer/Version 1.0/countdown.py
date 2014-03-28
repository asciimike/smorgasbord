import datetime

# This class uses imperial units for all values

class Countdown:
	def __init__(self, day, month, year, hour, minute):
		dt = datetime.datetime
		self.daysLeft = 0
		self.hoursLeft = 0
		self.minutesLeft = 0
		self.secondsLeft = 0
		self.date = dt(year, month, day, hour, minute)

	def __repr__(self):
		return str(self.daysLeft) + ' Days left\n' + str(self.hoursLeft) + ' Hours left\n' + str(self.minutesLeft) + ' Minutes left\n' + str(self.secondsLeft) + ' Seconds left'

	# TODO: clean up some of the cludge code here... especially for lengths
	def getMessage(self):
		line0 = 'GRADUATION COUNTDOWN'
		line1 = ' '
		while (len(line1) < 20):
			line1 += ' '
		if (len(line1) > 20):
			line1 = line1[:20]
		line2 = ' '
		while (len(line2) < 20):
			line2 += ' '
		line3 = ' '
		while (len(line3) < 20):
			line3 += ' '
		return line0 + line1.title() + line2 + line3

	def updateCountdown(self):
		dt = datetime.datetime
		now = dt.now()
		delta = self.date - dt(year = now.year, month = now.month, day = now.day, hour = now.hour, minute = now.minute)
		self.daysLeft = delta.days
		self.hoursLeft = delta.seconds/3600
		self.minutesLeft = (delta.seconds - (3600*self.hoursLeft))/60
		self.secondsLeft = (delta.seconds - (3600*self.hoursLeft) - (60*self.minutesLeft))