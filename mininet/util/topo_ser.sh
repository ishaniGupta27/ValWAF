#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.node import RemoteController, OVSSwitch

class FirstTopology(Topo):
	"""
	A basic topology of 3 hosts and 1 switch
	"""
        def __init__(self):
		Topo.__init__(self)
		switch_snort = self.addSwitch('s1') ## Adds a Switch
		switch_ryu = self.addSwitch('s2')
		host1 = self.addHost('cl') ## Adds a Host
		#host2 = self.addHost('pr') ## Adds a Host
		host2 = self.addHost('ser') ## Adds a Host

		self.addLink(host1, switch_snort) ## Add a link
		self.addLink(switch_snort, switch_ryu) ## Add a link
		self.addLink(switch_ryu, host2) ## Add a link

if __name__ == '__main__':
		"""
		If this script is run as an executable (by chmod +x), this is
		what it will do
		"""

		topo = FirstTopology() ## Creates the topology
		net = Mininet( topo=topo, controller=RemoteController ) ## Loads the topology
		net.start() ## Starts Mininet
		h2 = net.get('ser')
                rs = h2.sendCmd('sudo ./server_code.py')
                print rs
		CLI(net)
		net.stop() ## Stops Mininet
