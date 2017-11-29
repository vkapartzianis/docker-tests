# Zeppelin Docker

## Build a raw Docker Swarm on AWS IAAS

https://docs.docker.com/machine/drivers/aws/

### Specify an AWS profile to use

```
export AWS_PROFILE=[profile_name]
```

or use your AWS credentials `--amazonec2-access-key`, `--amazonec2-secret-key` in the next command line.

### Create a docker-machine as a swarm master

docker-machine command offers many options, see `docker-machine create -d amazonec2 -h`

```
docker-machine create --driver amazonec2 --amazonec2-open-port 8080 --amazonec2-open-port 80 --amazonec2-open-port 443 --amazonec2-region "us-east-1" --amazonec2-instance-type "t2.medium" --amazonec2-volume-type "gp2" --amazonec2-root-size 32 --swarm-master zp
```

* [AWS instance types](https://aws.amazon.com/fr/ec2/instance-types/)
* [AWS volume types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html)
### Select the active docker-machine to work with your Docker client

    eval $(docker-machine env zp)

Sometimes, it is necessary to regenerate the certificates when the remote instance has been stopped `docker-machine regenerate-certs [name]`. You may loose your current container state though.

### Add a Swarm worker

#### Open protocols and ports between the hosts
The following ports must be available. On some systems, these ports are open by default.

* TCP port 2377 for cluster management communications
* TCP and UDP port 7946 for communication among nodes
* UDP port 4789 for overlay network traffic

Open this ports in the AWS console `inbound rules`.

```
docker-machine create --driver amazonec2 --amazonec2-region "us-east-1" --amazonec2-instance-type "t2.medium" --swarm zp-swarm-1
```

### Swarm init

    eval $(docker-machine env zp)

    docker swarm init

this will return a token which will be used for joining a swarm node to the swarm master. eg: 

    docker swarm join --token SWMTKN-1-1jd8dhvbnstgdnlk0xizcrzugzantb22pohgh6358zha0xucmt-1wzz6kg02rfz5ehhvb4kin4hz xxx.xx.xx.xxx:2377

copy the whole command. Back to the swarm worker machine:

    eval $(docker-machine env zp-swarm-1)

then paste the command to join the swarm master node:

    docker swarm join --token ...

### Deploy the service (app)

```
docker service create --hostname localhost -p 8080:8080 --replicas 1 --detach=false --name zeppelin vkapartzianis/docker-tests
```

follow the logs

```
docker service logs -f zeppelin
```

### Get the IP

```
docker-machine ip
```

## Build a Docker stack based on the docker-compose v3 yml file

* use a docker-compose.yml file
* We may need a docker registry for all nodes to deploy the same image

https://docs.docker.com/engine/swarm/stack-deploy/

...