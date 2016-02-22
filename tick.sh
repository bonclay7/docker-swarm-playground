eval $(docker-machine env --swarm swarm-master)

pushd ./tick
export PROXY_IP=$(docker-machine ip tools)
docker-compose build
docker-compose up
popd

