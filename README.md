# docker-swarm-playground
Playground for docker-swarm

## Getting started

Download and install the dependencies

-   VirtualBox, see <https://www.virtualbox.org/wiki/Downloads>

-   Docker machine, docker compose, see <https://www.docker.com/products/docker-toolbox>

-   Nah, that's all !

## Build your docker cluster

We provide a little cluster of 4 vms running `boot2docker`

-   `tools` containing a local docker `registry` and a `squid` proxy for
    images and network caching ; `consul` for service discovery and key/value storage ;
    `zookeeper` for kafka

-   `swarm-master`, docker swarm master node

-   2 (see `SWARM_NODES`) `swarm nodes`, nodes that will receive containers apps

-   a `registrator` container on each swarm nodes (master included) to notify consul

-   plus an `overlay` network to make the communication work in this world !

```bash
./setup-cluster.sh
```

#### Ports

Opened ports on tools machine

| Ports              |     Services       |
| :----------------- | :----------------: |
| _8500_             |  Consul            |
| _5000_             |  Registry          |
| _3128_             |  Squid Proxy       |
| _2181_             |  Zookeeper         |

## Launch your services

### Ambari

The elephant on a boat

```bash
./ambari.sh
```

### Tick stack (Telegraf, InfluxDB, Chronograf, Kapacitor)

Effective stack by [influxdata](https://influxdata.com/) for telemetry

```bash
./tick.sh
```

#### Ports

| Ports        |     Services       |
| :---------   | :----------------: |
| _8083, 8086_ |  InfluxDB          |
| _10000_      |  Chronograf        |
| _9092_       |  Kapacitor         |
| _3000_       |  Grafana           |
