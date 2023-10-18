#!/bin/bash

Infon() {
	printf "\033[1;32m$@\033[0m"
}
Info()
{
	Infon "$@\n"
}
Error()
{
	printf "\033[1;31m$@\033[0m\n"
}
Error_n()
{
	Error "$@"
}
Error_s()
{
	Error "============================================"
}

menu()
{

}

vpn()
{
read file_name
sudo nano /etc/proxychains4.conf
#dynamic_chain
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install openvpn -y
sudo openvpn --config $file_name
}

OS_Safe()
{
read wlan_name
read dns_server
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install macchanger -y
sudo ifconfig wlan0 down && sudo macchanger -r wlan0 && sudo ifconfig $wlan_name up
sudo nano /etc/resolv.conf
nameserver $dns_server
}
tor()
{
ExitNodes {US, EU}
StrictExitNodes 1
propertions:/javascriptenable 0
}
