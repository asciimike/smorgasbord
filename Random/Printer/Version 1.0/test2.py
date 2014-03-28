from apscheduler.scheduler import Scheduler
import logging
from weather import *
from printer import *
from statemachine import *

def updateState(m):
	print "State is: " + str(m.state)
	m.incrementMachine()

def main():
	logging.basicConfig()
	sched = Scheduler(standalone=True)
	stateMachine = StateMachine(4)
	sched.add_interval_job(updateState, args = [stateMachine], seconds = 5)
	sched.start()

if __name__ == "__main__":
    main()
