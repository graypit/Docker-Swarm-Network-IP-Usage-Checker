#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  docker-network-ip-usage-checker.sh
#
#         USAGE:  docker-network-ip-usage-checker.sh --service service_name(or prefix) --network network_name
#
#   DESCRIPTION:  Print specific Docker Swarm networks ip usage for specific swarm services
#
#        AUTHOR:  Habib Guliyev (), hguliyev@gptlab.io
#        NUMBER:  +994777415001
#      POSITION:  SRE | DevOps Engineer
#       VERSION:  1.0
#       CREATED:  23/07/2022 1:25:17 PM +04
#      REVISION:  ---
#===============================================================================
# Define Parameters Array:
declare -A Param=(
[Service]="-s|--service"
[Network]="-n|--network"
[Mismatch]="-*|--*"
)
# Detect Parameters:
while [[ "$#" -gt 0 ]]
do
    if   [[ "$1" = @(${Param[Service]}) ]];then Service="$2" ; shift 2        
    elif [[ "$1" = @(${Param[Network]}) ]];then Network="$2" ; shift 2
    elif [[ "$1" = @(${Param[Mismatch]}) ]];then echo -e "${RED}./$(basename $0): Unknown flag: $1${NC}" ; exit 1
    else echo -e "${RED}./$(basename $0): "\'$1\'" is not a ./$(basename $0) command.${NC}" ; exit 1 ; fi
done
# Global variables:
appPrefix=$Service
source_network_id=$(docker network inspect $Network --format '{{ .Id }}')
source_network_name=$(docker network inspect $Network --format '{{ .Name }}')
# Main function to check docker specific network ip usage
function main() {
    allGlobalServiceCount=$(docker service ls --filter name="$appPrefix" --filter mode="global" --format '{{ .Name }}'|wc -l)
    allReplicatedServiceCount=$(docker service ls --filter name="$appPrefix" --filter mode="replicated" --format '{{ .Name }}'|wc -l)
    if [ "$allGlobalServiceCount" -ne 0 ]
    then
        globalServiceNames=$(docker service inspect $(docker service ls --filter name="$appPrefix" --filter mode="global" --format '{{ .Name }}') -f '{{ .Spec.Name }} {{range .Endpoint.VirtualIPs}}{{.NetworkID}} {{end}}'|grep "$source_network_id"|awk '{ print $1 }')
        globalServiceCount=$(docker service inspect $(docker service ls --filter name="$appPrefix" --filter mode="global" --format '{{ .Name }}') -f '{{range .Endpoint.VirtualIPs}}{{.NetworkID}} {{end}}'|grep "$source_network_id"|wc -l)
        for i in $globalServiceNames
        do 
            globalServiceReplicas=$[ $globalServiceReplicas + $(docker service ls --filter name="$i" --filter mode="global" --format '{{ .Replicas }}'|cut -f2 -d'/') + 1 ]
        done
    else
        globalServiceCount=$allGlobalServiceCount
        globalServiceReplicas=$allGlobalServiceCount
    fi
    if [ "$allReplicatedServiceCount" -ne 0 ]
    then 
        replicatedServiceNames=$(docker service inspect $(docker service ls --filter name="$appPrefix" --filter mode="replicated" --format '{{ .Name }}') -f '{{ .Spec.Name }} {{range .Endpoint.VirtualIPs}}{{.NetworkID}} {{end}}'|grep "$source_network_id"|awk '{ print $1 }')
        replicatedServiceCount=$(docker service inspect $(docker service ls --filter name="$appPrefix" --filter mode="replicated" --format '{{ .Name }}') -f '{{range .Endpoint.VirtualIPs}}{{.NetworkID}} {{end}}'|grep "$source_network_id"|wc -l)
        for i in $replicatedServiceNames
        do
            replicatedServiceReplicas=$[ $replicatedServiceReplicas + $(docker service inspect $i --format '{{.Spec.Mode.Replicated.Replicas}}') + 1 ]
        done
    else
        replicatedServiceCount=$allReplicatedServiceCount
        replicatedServiceReplicas=$allReplicatedServiceCount
    fi
    echo "There are $(expr $globalServiceCount + $replicatedServiceCount) $appPrefix services and $(expr $globalServiceReplicas + $replicatedServiceReplicas) IP Addresses already in use for $source_network_name network"
} 
main
