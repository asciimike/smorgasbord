import socket

class Printer:
	def __init__(self, ip):
		self.ip = ip

	def setReadyMessage(self, message):
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.settimeout(10)
		try:
			s.connect((self.ip, 9100))
			s.send('@PJL RDYMSG DISPLAY = ' + '"' + message + '"' + '\n')
		except socket.timeout:
			print 'Failed'
		s.close()

	def tryReadyMessage(self, message):
		print('@PJL RDYMSG DISPLAY = ' + '"' + message + '"' + '\n')