#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.cli import CLI

class FirstTopology(Topo):
	"""
	A basic topology of 3 hosts and 1 switch
	"""
        def __init__(self):
		Topo.__init__(self)
		switch = self.addSwitch('s1') ## Adds a Switch
		host1 = self.addHost('cl') ## Adds a Host
		host2 = self.addHost('pr') ## Adds a Host
		host3 = self.addHost('ser') ## Adds a Host
		
		self.addLink(host1, switch) ## Add a link
		self.addLink(host2, switch) ## Add a link
		self.addLink(host3, switch) ## Add a link

if __name__ == '__main__':
		"""
		If this script is run as an executable (by chmod +x), this is
		what it will do
		"""

		topo = FirstTopology() ## Creates the topology
		net = Mininet( topo=topo ) ## Loads the topology
		net.start() ## Starts Mininet
		CLI(net)
		net.stop() ## Stops Mininet
