from apscheduler.scheduler import Scheduler
from weather import *
from printer import *

def main():
	sched = Scheduler()
	@sched.interval_schedule(seconds=60)
	def updateWeather():
		ipList = ['192.168.1.21','192.168.1.20']
		latitude = 39.49
		longitude = -87.31
		w = Weather(latitude, longitude)
		w.refreshWeather()
		for ip in ipList:
			p = Printer(ip)
			p.setReadyMessage(w.getMessage())
	sched.start()
	while True:
		pass
	
    
if __name__ == "__main__":
    main()
