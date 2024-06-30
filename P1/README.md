# P1 GNS3 Configuration with Docker

This project involves the configuration of GNS3 with Docker to manage packet routing using FRRouting (zebra or quagga). The project includes pre-built images that need to be configured with BGPD, OSPFD, and IS-IS routing engine services.

## GNS3

GNS3 is a graphical network simulator that allows users to design and test complex network topologies. In this project, we use GNS3 to configure and test our Docker images with the required routing services.

## Docker Images

### FRRouting

FRRouting (FRR) is a free and open-source networking protocol suite that provides routing functionality for various IP protocols. It supports a wide range of routing protocols, including BGP, OSPF, RIP, IS-IS, and more. In this project, we use FRR to manage packet routing using the following services:

* Border Gateway Protocol Daemon (BGPD): BGPD is a daemon that manages BGP routing. It is responsible for establishing BGP sessions with other routers and exchanging routing information.
* Open Shortest Path First Daemon (OSPFD): OSPFD is a daemon that manages OSPF routing. It is responsible for maintaining the OSPF link-state database and calculating the shortest path to each destination.
* IS-IS Routing Engine Service: The IS-IS routing engine service is responsible for managing IS-IS routing. It maintains the IS-IS link-state database and calculates the shortest path to each destination.

We use the zebra implementations of FRR in this project. Zebra provides a routing daemon that manages the routing table and communicates with other routing daemons.

## Using zebra, bgpd, ospfd, and isisd

To configure our Docker images with the required services, we use the following commands:

* `zebra`: This command starts the Zebra daemon, which manages the routing table and communicates with other routing daemons.
* `bgpd`: This command starts the BGPD daemon, which manages BGP routing.
* `ospfd`: This command starts the OSPFD daemon, which manages OSPF routing.
* `isisd`: This command starts the IS-IS routing engine service, which manages IS-IS routing.

We also use Busybox or an equivalent to provide a minimal environment for running our Docker images.

## Project Requirements

* The Docker images must be configured to work in GNS3 with the required services.
* The name of the machines must include the login name of the user.
* The configuration files must be included in the project repository with comments explaining the setup of each equipment.
* The project must be rendered in a P1 folder at the root of the git repository.
* The project must be exported with a ZIP compression, including the base images.
* No IP address should be configured by default.

## Project Diagram

The following diagram shows the two Docker images configured in GNS3:

![Topology](../docs/p1.gns3.png)

This is the router:

![Router](../docs/p1.router.png)

## Conclusion

In this project, we configured GNS3 with Docker to manage packet routing using FRRouting (zebra). Using BGPD, OSPFD, and IS-IS routing engine services to manage routing and provide a minimal environment using Busybox or an equivalent.

## Glossary

| Term                 | Definition                                                                                               |
|----------------------|----------------------------------------------------------------------------------------------------------|
| **Autonomous System (AS)** | A collection of IP networks and routers under the control of a single organization that presents a common routing policy to the internet. Identified by a unique ASN (Autonomous System Number). |
| **IGP (Interior Gateway Protocol)** | Protocol used for routing within an autonomous system. Examples include RIP, OSPF, and IS-IS. |
| **EGP (Exterior Gateway Protocol)** | Protocol used for routing between autonomous systems. The primary example is BGP. |
| **RIP (Routing Information Protocol)** | An older IGP that uses hop count as a routing metric, with a maximum of 15 hops. It periodically sends its entire routing table to all neighbors. |
| **OSPF (Open Shortest Path First)** | An IGP that uses link-state routing to maintain a map of the network and calculate the shortest path using Dijkstra's algorithm. |
| **IS-IS (Intermediate System to Intermediate System)** | A link-state routing protocol used within an AS to determine the best path for data using various metrics. |
| **BGP (Border Gateway Protocol)** | An EGP used to exchange routing information between autonomous systems. It uses TCP port 179 and supports route reflectors for reduced connections. |
| **BGP-EVPN (Ethernet VPN)** | An extension of BGP providing a control plane for VXLAN, advertising MAC and IP addresses between VXLAN Tunnel Endpoints (VTEPs). |
| **VXLAN (Virtual Extensible LAN)** | A network virtualization technology for scalable cloud computing deployments, encapsulating Ethernet frames within UDP packets. |
| **VNI (VXLAN Network Identifier)** | A 24-bit segment ID used to identify VXLAN segments, similar to VLAN IDs but with a larger address space. |
| **VTEP (VXLAN Tunnel Endpoint)** | Responsible for encapsulating and de-encapsulating packets into and out of VXLAN tunnels, mapping VNIs to MAC addresses. |
| **Zebra (protocol)** | Used by routing protocol daemons to communicate with the Zebra daemon, which manages routing information and installs routes in the kernel's forwarding table. |
| **Zebra (software)** | A routing software suite that included implementations of BGP, OSPF, RIP, and IS-IS. Now discontinued. |
| **Quagga** | A fork of Zebra that continued the development of the routing software suite, now also discontinued. |
| **FRRouting (FRR)** | A fork of Quagga that is an active project continuing the development and maintenance of the routing software suite, supporting various protocols. |
