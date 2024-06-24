# P2 Discovering a VXLAN

Glossary
--------

| Term | Definition |
| --- | --- |
| VXLAN | Virtual Extensible LAN, a network virtualization technology that enables the creation of Layer 2 networks over Layer 4 networks. VXLAN uses a UDP-based encapsulation mechanism to encapsulate Layer 2 frames within Layer 4 packets, allowing for the creation of virtual Layer 2 networks over a Layer 3 network infrastructure. |
| VTEP | Virtual Tunnel Endpoint, a logical entity that acts as a termination point for VXLAN tunnels. VTEPs are responsible for encapsulating and decapsulating VXLAN packets and forwarding them to the appropriate destination. |
| Peer-to-peer | A type of VXLAN configuration where each VTEP is configured to send traffic directly to the other VTEP. In this configuration, the VTEPs are configured with the IP address of the other VTEP as the destination for all VXLAN traffic. |
| Multicast | A type of VXLAN configuration where VTEPs use a multicast address to communicate with each other. In this configuration, VTEPs send multicast messages to all other VTEPs present on the multicast group when they receive a packet with an unknown destination MAC address. |
| Router | A networking device that forwards data packets between computer networks. Routers connect two or more networks and route packets based on their IP address. |
| Switch | A networking device that connects devices together on a computer network by using packet switching to receive, process, and forward data to the destination device. Switches operate at the data link layer (Layer 2) of the OSI model. |
| Host | A computer or other device connected to a computer network. Hosts can communicate with each other over the network by exchanging data packets. |
| Link | A communication channel between two devices. In networking, a link refers to the physical or logical connection between two devices. |
| IP address | A unique identifier assigned to each device on a computer network. IP addresses are used to route data packets between devices on the network. |
| Subnet | A logical subdivision of an IP network. Subnets are used to divide a larger network into smaller, more manageable segments. |
| MAC address | A unique identifier assigned to a network interface controller (NIC) for use as a network address in communications within a network segment. MAC addresses are used to identify devices on a LAN. |
| UDP | User Datagram Protocol, a connectionless transport protocol used for sending datagrams over IP networks. UDP is used as the transport protocol for VXLAN encapsulation. |
| TTL | Time to Live, a value that indicates how long a packet should remain in the network before being discarded. The TTL value is set by the sender of the packet and is decremented by each router that forwards the packet. If the TTL value reaches zero, the packet is discarded. |

VXLAN Configuration
-------------------

This guide will walk you through the process of creating a basic VXLAN between two computers. The VXLAN can be configured statically, using a peer-to-peer connection, or dynamically, using a multicast address.

Network Diagram
--------------

The current network diagram is as follows:
![Network diagram](../docs/p2.topology.png)

IP Address Configuration
------------------------

To enable communication between the various network elements, we need to assign them valid IP addresses. The following commands can be used to set the IP addresses:
```bash
ip address add <ip_address>/<mask> dev <interface_name>
```
### Router-1 IP Address
```bash
ip address add 20.1.1.1/24 dev eth0
```
### Router-2 IP Address
```bash
ip address add 20.1.1.2/24 dev eth0
```
### Host-1 IP Address
```bash
ip address add 30.1.1.1/24 dev eth0
```
### Host-2 IP Address
```bash
ip address add 30.1.1.2/24 dev eth0
```
VXLAN Configuration
-------------------

For a peer-to-peer configuration, we need to specify the IP address of the other VTEP. The following command can be used:
```bash
ip link add name <name> type vxlan id <vni> remote <destination_ip> dstport <destination_port> dev <device>
```
For a multicast configuration, we need to specify the multicast IP address. The following command can be used:
```bash
ip link add name <name> type vxlan id <vni> group <multicast_ip> dstport <destination_port> dev <device>
```
Explanation of the command:

* `ip`: Command to manage the network device
* `link`: Subcommand to manage the network device
* `id ID`: Specifies the VXLAN Network Identifier (VNI) to use
* `local IPADDR`: (optional) specifies the source IP address to use in outgoing packets
* `remote IPADDR`: specifies the remote VXLAN tunnel endpoint IP address to use for outgoing packets
* `group IPADDR`: specifies the multicast IP address to join. This parameter cannot be specified with the remote parameter and is required for multicast
* `dstport PORT`: specifies the UDP destination port to use for outgoing packets. The standard port for VXLAN is 4789
* `dev NAME`: specifies the physical device to use for tunnel endpoint communication

Other options:

* `-4`: (optional) specifies the internet protocol version, in this case IPv4
* `ttl TTL`: (optional) specifies the Time to Live (TTL) to use for outgoing packets

We also need to create a bridge to connect the VXLAN to the physical network device. The following commands can be used:
```bash
ip link add name br0 type bridge # create the bridge with the name br0
ip link set br0 up # start the bridge
ip link set vxlan10 up # start the vxlan
ip link set vxlan10 master br0 # connect the vxlan to the bridge
ip link set eth1 master br0 # connect the physical device to the bridge
```
Alternatively, the `brctl` command can be used to manage the bridge:
```bash
brctl addbr br0 # create the bridge with the name br0
brctl addif br0 vxlan10 # connect the vxlan to the bridge
brctl addif br0 eth1 # connect the physical device to the bridge
```
Static VXLAN Configuration
--------------------------

### Router-1 (VTEP)
```bash
ip link add name vxlan10 type vxlan id 10 remote 20.1.1.2 dstport 4789 dev eth0
ip link add name br0 type bridge
ip link set br0 up
ip link set vxlan10 up
ip link set vxlan10 master br0
ip link set eth1 master br0
```
### Router-2 (VTEP)
```bash
ip link add name vxlan10 type vxlan id 10 remote 20.1.1.1 dstport 4789 dev eth0
ip link add name br0 type bridge
ip link set br0 up
ip link set vxlan10 up
ip link set vxlan10 master br0
ip link set eth1 master br0
```
Dynamic/Multicast VXLAN Configuration
--------------------------------------

The goal of multicast is to send packets to all devices in the network. A multicast group is a group of devices that listen to a specific IP address. When a device sends a packet to the multicast IP address, all devices in the multicast group receive the packet.

To improve performance and limit the number of multicasts on the network, each VTEP creates a table of correspondences between MAC addresses and VTEP IP addresses. This table can be displayed with the following command:
```bash
bridge fdb show dev vxlan10
```
### Router-1 (VTEP)
```bash
ip link add name vxlan10 type vxlan id 10 group 239.1.1.1 dstport 4789 dev eth0
ip link add name br0 type bridge
ip link set br0 up
ip link set vxlan10 up
ip link set vxlan10 master br0
ip link set eth1 master br0
```
### Router-2 (VTEP)
```bash
ip link add name vxlan10 type vxlan id 10 group 239.1.1.1 dstport 4789 dev eth0
ip link add name br0 type bridge
ip link set br0 up
ip link set vxlan10 up
ip link set vxlan10 master br0
ip link set eth1 master br0
```
Conclusion
----------

In this guide, we have learned how to create a basic VXLAN between two computers using static and dynamic configuration. We have also learned how to assign IP addresses to network elements and create a bridge to connect the VXLAN to the physical network device. With this knowledge, you should now be able to configure a VXLAN in your own network environment.

