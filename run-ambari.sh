eval $(docker-machine env --swarm swarm-master)

AMBARI_NODES=1
echo "Run ambari master"
docker run -d --restart=always \
  --hostname=ambari-master.swarm-net \
  --name=ambari-master \
  --net=swarm-net \
  -p 8080 \
  ambari_server

for i in $( seq 1 $AMBARI_NODES ); do
  echo "Run ambari node $i"
  docker run -d --restart=always \
    -e AMBARI_SERVER_FQDN=ambari-master.swarm-net \
    --hostname=ambari-node$i.swarm-net \
    --name=ambari-node$i \
    --net=swarm-net \
    ambari_agent
done

