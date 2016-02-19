pushd ./services
export PROXY_IP=$(docker-machine ip tools)
docker-compose build
docker-compose up
popd

