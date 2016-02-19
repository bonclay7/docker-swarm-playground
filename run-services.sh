pushd ./services
export PROXY_IP=$(docker-machine ip registry)
docker-compose build
docker-compose up
popd

