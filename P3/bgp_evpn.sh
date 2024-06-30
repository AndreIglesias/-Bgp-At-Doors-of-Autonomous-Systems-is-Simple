#!/bin/bash

ROUTER1="router_ciglesia-1"
ROUTER2="router_ciglesia-2"
ROUTER3="router_ciglesia-3"
ROUTER4="router_ciglesia-4"
HOST1="host_ciglesia-1"
HOST2="host_ciglesia-2"
HOST3="host_ciglesia-3"

# Function to execute vtysh commands
execute_vtysh() {
    local container=$1
    shift
    local cmds="$@"
    docker exec $container vtysh -c "$cmds"
}

# Function to configure Router 1
configure_router1() {
    local container=$1
    echo "Configuring $ROUTER1"
    execute_vtysh $container \
        "conf t" \
        "hostname $ROUTER1" \
        "no ipv6 forwarding" \
        "interface eth0" \
        "ip address 10.1.1.1/30" \
        "interface eth1" \
        "ip address 10.1.1.5/30" \
        "interface eth2" \
        "ip address 10.1.1.9/30" \
        "interface lo" \
        "ip address 1.1.1.1/32" \
        "router bgp 1" \
        "neighbor ibgp peer-group" \
        "neighbor ibgp remote-as 1" \
        "neighbor ibgp update-source lo" \
        "bgp listen range 1.1.1.0/29 peer-group ibgp" \
        "address-family l2vpn evpn" \
        "neighbor ibgp activate" \
        "neighbor ibgp route-reflector-client" \
        "exit-address-family" \
        "router ospf" \
        "network 0.0.0.0/0 area 0" \
        "line vty"
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

    execute_vtysh $container \
        "conf t" \
        "hostname $hostname" \
        "no ipv6 forwarding" \
        "interface eth0" \
        "ip address $eth0_ip" \
        "ip ospf area 0" \
        "interface lo" \
        "ip address $lo_ip" \
        "ip ospf area 0" \
        "router bgp 1" \
        "neighbor 1.1.1.1 remote-as 1" \
        "neighbor 1.1.1.1 update-source lo" \
        "address-family l2vpn evpn" \
        "neighbor 1.1.1.1 activate" \
        "advertise-all-vni" \
        "exit-address-family" \
        "router ospf"
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
                configure_router1 $container
                ;;
            $ROUTER2)
                configure_router $container $ROUTER2 "10.1.1.2/30" "1.1.1.2/32"
                ;;
            $ROUTER3)
                configure_router $container $ROUTER3 "10.1.1.6/30" "1.1.1.3/32"
                ;;
            $ROUTER4)
                configure_router $container $ROUTER4 "10.1.1.10/30" "1.1.1.4/32"
                ;;
            $HOST1)
                configure_host $container "30.1.1.1/24"
                ;;
            $HOST2)
                configure_host $container "30.1.1.2/24"
                ;;
            $HOST3)
                configure_host $container "30.1.1.3/24"
                ;;
            *)
                echo " - No configuration needed for $container_hostname -"
                ;;
        esac
    done
}

main
