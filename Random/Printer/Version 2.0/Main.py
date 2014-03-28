from apscheduler.scheduler import Scheduler
import logging

from ContentWeather import *
from Printer import *
from Content import *
from ContentProvider import *

def updateContent(contentProvider):
	content = contentProvider.getNextContent()
	content.updateContent()
	contentToDisplay = content.getContent()
	ipList = ['192.168.1.21','192.168.1.20']
	for ip in ipList:
		p = Printer(ip)
		p.tryReadyMessage(contentToDisplay)
		#p.setReadyMessage(contentToDisplay)


def main():
	logging.basicConfig()
	sched = Scheduler(standalone=True)
	latitude = 39.49
	longitude = -87.31
	w = ContentWeather(latitude, longitude)
	contentToDisplay = [w]
	contentProvider = ContentProvider(contentToDisplay)
	sched.add_interval_job(updateContent, args = [contentProvider], seconds = 5)
	sched.start()

if __name__ == "__main__":
    main()
