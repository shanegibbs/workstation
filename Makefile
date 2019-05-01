build:
	docker build $(BUILD_ARGS) -t workstation .

run:
	docker run --name workstation --rm -it --net=host  \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(HOME)/workstation:/workstation \
		workstation

#		-v /home/sgibbs/workstation/ssh:/home/sgibbs/.ssh \
#		-v /home/sgibbs/workstation/gnupg:/home/sgibbs/.gnupg \
#		-v /home/sgibbs/workstation/kube:/home/sgibbs/.kube \
#		-v /home/sgibbs/workstation/aws:/home/sgibbs/.aws \
#		-v /home/sgibbs/dev:/home/sgibbs/dev \
#		-v /home/sgibbs/local:/home/sgibbs/local \
#		-v /home/sgibbs/projects:/home/sgibbs/projects \

run-simple:
	docker run --rm -it --name workstation --tmpfs /run --net=host --pid=host \
		workstation

stop:
	docker stop workstation
