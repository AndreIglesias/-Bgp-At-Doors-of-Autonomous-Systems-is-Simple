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

We use the zebra and quagga implementations of FRR in this project. Zebra provides a routing daemon that manages the routing table and communicates with other routing daemons. Quagga is a fork of Zebra that provides additional features and improvements.

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

![alt text](../docs/p1.gns3.png)

## Conclusion

In this project, we configured GNS3 with Docker to manage packet routing using FRRouting (zebra or quagga). Using BGPD, OSPFD, and IS-IS routing engine services to manage routing and provide a minimal environment using Busybox or an equivalent.