#!/usr/bin/python

import bluetooth

targets = {"78:02:F8:03:68:30":"/presence/pasha"}

def scan():
	nearby_devices = bluetooth.discover_devices(lookup_names=True)
	print("found %d devices" % len(nearby_devices))

	for addr, name in nearby_devices:
    		print("  %s - %s" % (addr, name))


def monitor():
	while True:
		nearby_devices = bluetooth.discover_devices(lookup_names=True)
		
		for addr, name in nearby_devices:
			if targets.get(addr):
				print("%s" % (targets[addr]))


monitor()
