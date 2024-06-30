#!/bin/bash

ROUTER1="router_ciglesia-1"
ROUTER2="router_ciglesia-2"
ROUTER3="router_ciglesia-3"
ROUTER4="router_ciglesia-4"
HOST1="host_ciglesia-1"
HOST2="host_ciglesia-2"
HOST3="host_ciglesia-3"

# Function to reset a router
reset_router() {
    local container=$1
    echo "Resetting router $container"
    docker exec $container bash -c "
        ip address flush dev eth0;
        ip address flush dev eth1 2>/dev/null || true;
        ip address flush dev eth2 2>/dev/null || true;
        ip link del br0 2>/dev/null || true;
        ip link del vxlan10 2>/dev/null || true;
    "
}

# Function to reset a host
reset_host() {
    local container=$1
    echo "Resetting host $container"
    docker exec $container ip address flush dev eth0
}

# Function to configure Router 1
configure_router1() {
    local container=$1
    echo "Configuring $ROUTER1"
    docker exec $container vtysh \
        -c "conf t" \
        -c "hostname $ROUTER1" \
        -c "no ipv6 forwarding" \
        -c "interface eth0" \
        -c "ip address 10.1.1.1/30" \
        -c "interface eth1" \
        -c "ip address 10.1.1.5/30" \
        -c "interface eth2" \
        -c "ip address 10.1.1.9/30" \
        -c "interface lo" \
        -c "ip address 1.1.1.1/32" \
        -c "router bgp 1" \
        -c "neighbor ibgp peer-group" \
        -c "neighbor ibgp remote-as 1" \
        -c "neighbor ibgp update-source lo" \
        -c "bgp listen range 1.1.1.0/29 peer-group ibgp" \
        -c "address-family l2vpn evpn" \
        -c "neighbor ibgp activate" \
        -c "neighbor ibgp route-reflector-client" \
        -c "exit-address-family" \
        -c "router ospf" \
        -c "network 0.0.0.0/0 area 0" \
        -c "line vty"
}

# Function to configure Router 2, 3, and 4
configure_router() {
    local container=$1
    local hostname=$2
    local eth0_ip=$3
    local lo_ip=$4
    echo "Configuring $hostname"

    docker exec $container bash -c "
        ip link add br0 type bridge;
        ip link set dev br0 up;
        ip link add vxlan10 type vxlan id 10 dstport 4789;
        ip link set dev vxlan10 up;
        brctl addif br0 vxlan10;
        brctl addif br0 eth1;
    "

    docker exec $container vtysh \
        -c "conf t" \
        -c "hostname $hostname" \
        -c "no ipv6 forwarding" \
        -c "interface eth0" \
        -c "ip address $eth0_ip" \
        -c "ip ospf area 0" \
        -c "interface lo" \
        -c "ip address $lo_ip" \
        -c "ip ospf area 0" \
        -c "router bgp 1" \
        -c "neighbor 1.1.1.1 remote-as 1" \
        -c "neighbor 1.1.1.1 update-source lo" \
        -c "address-family l2vpn evpn" \
        -c "neighbor 1.1.1.1 activate" \
        -c "advertise-all-vni" \
        -c "exit-address-family" \
        -c "router ospf"
}

# Function to configure a host
configure_host() {
    local container=$1
    local ip_address=$2
    echo "Configuring host with IP $ip_address"
    docker exec $container ip address add $ip_address dev eth0
}

# Main function to iterate over containers and apply configurations
main() {
    for container in $(docker ps -q); do
        # Get container info
        container_name=$(docker inspect --format='{{.Name}}' $container)
        container_hostname=$(docker exec -it $container hostname)
        container_hostname=${container_hostname::-1}

        echo "----------------------------------------"
        echo "Host: $container_hostname"
        echo "Container: $container_name"
        echo "Container ID: $container"

        # Apply configuration based on the hostname
        case "$container_hostname" in
            $ROUTER1)
                reset_router $container
                configure_router1 $container
                ;;
            $ROUTER2)
                reset_router $container
                configure_router $container $ROUTER2 "10.1.1.2/30" "1.1.1.2/32"
                ;;
            $ROUTER3)
                reset_router $container
                configure_router $container $ROUTER3 "10.1.1.6/30" "1.1.1.3/32"
                ;;
            $ROUTER4)
                reset_router $container
                configure_router $container $ROUTER4 "10.1.1.10/30" "1.1.1.4/32"
                ;;
            $HOST1)
                reset_host $container
                configure_host $container "20.1.1.1/24"
                ;;
            $HOST2)
                reset_host $container
                configure_host $container "20.1.1.2/24"
                ;;
            $HOST3)
                reset_host $container
                configure_host $container "20.1.1.3/24"
                ;;
            *)
                echo " - No configuration needed for $container_hostname -"
                ;;
        esac
    done
}

main
