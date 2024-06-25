#!/bin/bash

ROUTER1="router_ciglesia-1"
ROUTER2="router_ciglesia-2"
HOST1="host_ciglesia-1"
HOST2="host_ciglesia-2"

# Function to reset a router
reset_router() {
    local container=$1
    echo "Resetting router $container"
    cmd="
        ip address flush dev eth0 &&
        ip link del vxlan10 2>/dev/null || true &&
        ip link del br0 2>/dev/null || true
    "
    echo "Running command: docker exec $container sh -c \"$cmd\""
    docker exec $container sh -c "$cmd"
}

# Function to configure a router
configure_router() {
    local container=$1
    local ip_address=$2
    local remote_ip=$3

    echo "Configuring router with IP $ip_address and remote IP $remote_ip"
    cmd="
        ip address add $ip_address dev eth0 &&
        ip link add name vxlan10 type vxlan id 10 remote $remote_ip dstport 4789 dev eth0 &&
        ip link add name br0 type bridge &&
        ip link set br0 up &&
        ip link set vxlan10 up &&
        ip link set vxlan10 master br0 &&
        ip link set eth1 master br0
    "
    echo "Running command: docker exec $container sh -c \"$cmd\""
    docker exec $container sh -c "$cmd"
}

# Function to reset a host
reset_host() {
    local container=$1
    echo "Resetting host $container"
    cmd="
        ip address flush dev eth0
    "
    echo "Running command: docker exec $container sh -c \"$cmd\""
    docker exec $container sh -c "$cmd"
}

# Function to configure a host
configure_host() {
    local container=$1
    local ip_address=$2

    echo "Configuring host with IP $ip_address"
    cmd="ip address add $ip_address dev eth0"
    echo "Running command: docker exec $container sh -c \"$cmd\""
    docker exec $container sh -c "$cmd"
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

        # Reset and apply configuration based on the hostname
        case "$container_hostname" in
            $ROUTER1)
                echo " - Resetting and Configuring $ROUTER1 -"
                reset_router $container
                configure_router $container "20.1.1.1/24" "20.1.1.2"
                ;;
            $ROUTER2)
                echo " - Resetting and Configuring $ROUTER2 -"
                reset_router $container
                configure_router $container "20.1.1.2/24" "20.1.1.1"
                ;;
            $HOST1)
                echo " - Resetting and Configuring $HOST1 -"
                reset_host $container
                configure_host $container "30.1.1.1/24"
                ;;
            $HOST2)
                echo " - Resetting and Configuring $HOST2 -"
                reset_host $container
                configure_host $container "30.1.1.2/24"
                ;;
            *)
                echo " - No configuration needed for $container_hostname -"
                ;;
        esac
    done
}

main
