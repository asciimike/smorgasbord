import requests

# This class uses imperial units for all values

class Weather:
	def __init__(self, latitude, longitude):
		self.latitude = latitude
		self.longitude = longitude
		self.currentTemperature = 0.0
		self.pressure = 0.0
		self.humidity = 0.0
		self.windSpeed = 0.0
		self.windDirection = 0.0
		self.windCode = ''
		self.currentWeather = ''

	def __repr__(self):
		return "Current weather is: " + self.currentWeather + "\n" + "Current Temp: " + str(self.currentTemperature) + " F\n" + "Current Pressure: " + str(self.pressure/10.0) + " kPa\n" + "Current Humidity: " + str(self.humidity) + "%\n" + "Wind Speed: " + str(self.windSpeed) + " mph\n" + "Wind Direction: " + str(self.windDirection) + " deg"

	# TODO: clean up some of the cludge code here... especially for lengths
	def getMessage(self):
		line0 = '  CURRENT WEATHER:  '
		line1 = ((20 - len(self.currentWeather))/2)*' ' + self.currentWeather + ((20 - len(self.currentWeather))/2)*' '
		while (len(line1) < 20):
			line1 += ' '
		if (len(line1) > 20):
			line1 = line1[:20]
		line2 = ((14 - len(str(self.currentTemperature)) - len(str(self.pressure)))/2)*' ' + str(self.currentTemperature) + 'F ' + str(self.pressure/10.0) + 'kPa ' + ((14 - len(str(self.currentTemperature)) - len(str(self.pressure)))/2)*' '
		while (len(line2) < 20):
			line2 += ' '
		line3 = ((10 - len(str(self.humidity)) - len(str(self.windSpeed)) - len(self.windCode))/2)*' ' + str(self.humidity) + '% RH ' + str(self.windSpeed) + ' mph ' + self.windCode + ((10 - len(str(self.humidity)) - len(str(self.windSpeed)) - len(self.windCode))/2)*' '
		while (len(line3) < 20):
			line3 += ' '
		return line0 + line1.title() + line2 + line3

	def windCodeFromDirection(self, direction):
		if (direction >= 0 and direction < 22.5):
			return 'N'
		elif (direction >= 22.5 and direction < 67.5):
			return 'NE'
		elif (direction >= 67.5 and direction < 112.5):
			return 'E'
		elif (direction >= 112.5 and direction < 157.5):
			return 'SE'
		elif (direction >= 157.5 and direction < 202.5):
			return 'S'
		elif (direction >= 202.5 and direction < 247.5):
			return 'SW'
		elif (direction >= 247.5 and direction < 292.5):
			return 'W'
		elif (direction >= 292.5 and direction < 337.5):
			return 'NW'
		elif (direction >= 337.5 and direction < 360):
			return 'N'
		else:
			return 'N/A'

	def refreshWeather(self):
		try:
			weatherDictionary = requests.get('http://api.openweathermap.org/data/2.5/weather?lat=' + str(self.latitude) + '&lon=' + str(self.longitude) + '&units=imperial').json()
		except requests.exceptions.ConnectionError:
			print "Connection failed\n"
			return
		self.currentTemperature = weatherDictionary['main']['temp']
		self.pressure = weatherDictionary['main']['pressure']
		self.humidity = weatherDictionary['main']['humidity']
		self.windSpeed = weatherDictionary['wind']['speed']
		self.windDirection = weatherDictionary['wind']['deg']
		self.windCode = self.windCodeFromDirection(self.windDirection)
		self.currentWeather = str(weatherDictionary['weather'][0]['description'])



