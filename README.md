# Docker Swarm Network IP Usage Checker

This script was written to check the number of IP addresses already in use for a specific services(we can use prefix) with specific network.

## What will this script do ?
When we have a lot of services in Docker Swarm,we offen need to check the number of IP addresses already in use for specific network.
Based on official Docker documentation,it is not recommended to create larger subnets than the one that we have without having external LB.If you need more than 256 IP addresses, do not increase the IP block size - use multiple smaller overlay networks.

So,with this setup (using smaller overlay networks) we will achieve to have around 80 application on each our service.

## How to check:
Just execute the script with arguments
- If you need to check all services that start with `backend-app` name and use `backends` network,just execute the following command:
```bash
$ ./docker-network-ip-usage-checker.sh --service backend-app --network backends
```
- If you need to check only the `main-api-server` service that uses `common` network,just execute the following command:
```bash
$ ./docker-network-ip-usage-checker.sh --service main-api-server --network common
```
## Examples:
### We've checked in production all services that start with `backend-app` name and use `backends` network,here is output:
```bash
$ ./docker-network-ip-usage-checker.sh --service backend-app --network backends
$ There are 73 backend-app services and 233 IP Addresses already in use for backends network
```
### We've checked in production all services that start with `mfe_ui` name and use `frontends` network,here is output:
```bash
$ ./docker-network-ip-usage-checker.sh --service mfe_ui --network frontends
$ There are 58 mfe_ui services and 176 IP Addresses already in use for frontends network
```
### We've checked in production only the `main-api-server` service that uses `common` network in global service mode,here is output:
```bash
$ ./docker-network-ip-usage-checker.sh --service main-api-server --network common
$ There are 1 main-api-server services and 11 IP Addresses already in use for common network
```
&copy; DevOps team of GPT LAB. LLC 2022
