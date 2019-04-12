build:
	docker build -t workstation .

run:
	docker run --name workstation --rm -it --net=host --pid=host -d \
		-v /tmp:/tmp \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /home/sgibbs/dev:/home/shane/dev \
		-v /home/sgibbs/local:/home/shane/local \
		-v /home/sgibbs/projects:/home/shane/projects \
		workstation

stop:
	docker stop workstation
