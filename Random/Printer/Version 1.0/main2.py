from apscheduler.scheduler import Scheduler
import logging
from weather import *
from printer import *

def main():
	logging.basicConfig()
	sched = Scheduler(standalone=True)
	state = 1
	@sched.interval_schedule(seconds=10)
	def updateWeather():
		state = state + 1
		ipList = ['192.168.1.21','192.168.1.20']
		latitude = 39.49
		longitude = -87.31
		#w = Weather(latitude, longitude)
		#w.refreshWeather()
		#for ip in ipList:
		#	p = Printer(ip)
		#	p.tryReadyMessage(w.getMessage())
			#p.setReadyMessage(w.getMessage())
		print "State is: " + state
	sched.start()
	
    
if __name__ == "__main__":
    main()
