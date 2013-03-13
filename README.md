learning-puppet
===============

bind/

	WARNING: module is tailored to a request and might not be usefull for many,
	but I've learned how to use stored configs while working on it so it may help others

	In this folder there is rough bind module that uses stored configs to populate 2 dns zones:
	- one direct zone with A records 
	- one reverse zone
	Module has some assumptions:
	- all IPs are from 10.0.0.0/8 (like AWS)
	- reverse is 10.in-addr.arpa.
	- you have only one dns zone
	- that dns zone has 2 entries for each servers


