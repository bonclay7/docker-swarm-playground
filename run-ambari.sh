AMBARI_NODES=1
echo "Run ambari master"
docker run -d --restart=always \
  --hostname=ambari-master.swarm-net \
  --name=ambari-master \
  --net=swarm-net \
  -p 8080 \
  whylu/docker-ambari:server

for i in $( seq 1 $AMBARI_NODES ); do
  echo "Run ambari node $i"
  docker run -d --restart=always \
    -e SERVER_FQDN=ambari-master.swarm-net \
    --hostname=ambari-node$i.swarm-net \
    --name=ambari-node$i \
    --net=swarm-net \
    whylu/docker-ambari:agent
done

