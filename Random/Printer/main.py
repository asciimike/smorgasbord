import sched, time
from weather import *
from printer import *

def updateWeather(s):
	ipList = ['192.168.1.21','192.168.1.20']
	latitude = 39.49
	longitude = -87.31
	w = Weather(latitude, longitude)
	w.refreshWeather()
	# print(w.getMessage())
	for ip in ipList:
		p = Printer(ip)
		p.setReadyMessage(w.getMessage())
		#p.tryReadyMessage(w.getMessage())
	s.enter(60, 1, updateWeather, (s,))


def main():
	s = sched.scheduler(time.time,time.sleep)
	s.enter(60,1, updateWeather, (s,))
	s.run()
	# TCP_IP = '192.168.1.21'
	# TCP_PORT = 9100
	# MESSAGE = '@PJL RDYMSG DISPLAY = "Hello, World"' + '\n'

	# s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	# s.connect((TCP_IP,TCP_PORT))
	# s.send(MESSAGE)
	# s.close()


if __name__ == "__main__":
    main()
