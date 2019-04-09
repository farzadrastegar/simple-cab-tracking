.PHONY: docker-build docker-swarm-init docker-deploy-services

docker-swarm-init:
	docker swarm init

docker-swarm-leave:
	docker swarm leave --force

docker-build:
	docker build --build-arg moduleName=gateway -t farzadras/gateway -f ./support/docker/simple-cab/Dockerfile-moduleName .
	docker build --build-arg moduleName=zombie_driver -t farzadras/zombie_driver -f ./support/docker/simple-cab/Dockerfile-moduleName .
	docker build --build-arg moduleName=driver_location -t farzadras/driver_location -f ./support/docker/simple-cab/Dockerfile-moduleName .
	docker rmi $$(docker images -q -f dangling=true)

docker-swarm-deploy-services:
	docker stack deploy --compose-file ./support/docker/services/swarm/docker-compose-s1.yaml services
	./support/docker/services/swarm/scripts/wait-for-rabbitmq.bash
	./support/docker/services/swarm/scripts/wait-for-redis.bash
	./support/docker/services/swarm/scripts/wait-for-nsqlookupd.bash
	./support/docker/services/swarm/scripts/wait-for-elasticsearch.bash
	docker stack deploy --compose-file ./support/docker/services/swarm/docker-compose-s2.yaml services
	./support/docker/services/swarm/scripts/wait-for-configserver.bash "gateway"
	./support/docker/services/swarm/scripts/wait-for-configserver.bash "zombie_driver"
	./support/docker/services/swarm/scripts/wait-for-configserver.bash "driver_location"
	./support/docker/services/swarm/scripts/wait-for-logstash.bash 9500
	./support/docker/services/swarm/scripts/wait-for-kibana.bash
	docker stack deploy --compose-file ./support/docker/services/swarm/docker-compose-s3.yaml services

docker-swarm-rm-services:
	docker stack rm services
	docker rm -f $$(docker ps -a -q)
	docker rmi $$(docker images -q -f dangling=true)

docker-build-rabbitmq:
	docker build -t farzadras/rabbitmq -f ./support/docker/rabbitmq/Dockerfile .

docker-build-configserver:
	cd support/config-server/; ./run.bash; cd -
	docker build -t farzadras/configserver support/config-server/
	docker rmi $$(docker images -q -f dangling=true)

docker-deploy-services:
	nohup docker-compose -f support/docker/services/localhost/docker-compose.yaml up >docker-deploy-services.out 2>&1 &

docker-rm-services:
	docker-compose -f support/docker/services/localhost/docker-compose.yaml down -v


