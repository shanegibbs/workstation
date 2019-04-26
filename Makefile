build:
	docker build $(BUILD_ARGS) -t workstation .

run:
	docker run --name workstation --rm -it --net=host --pid=host -d \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /home/sgibbs/workstation/ssh:/home/sgibbs/.ssh \
		-v /home/sgibbs/workstation/gnupg:/home/sgibbs/.gnupg \
		-v /home/sgibbs/workstation/kube:/home/sgibbs/.kube \
		-v /home/sgibbs/workstation/aws:/home/sgibbs/.aws \
		-v /home/sgibbs/workstation:/home/sgibbs/workstation \
		-v /home/sgibbs/dev:/home/sgibbs/dev \
		-v /home/sgibbs/local:/home/sgibbs/local \
		-v /home/sgibbs/projects:/home/sgibbs/projects \
		workstation

stop:
	docker stop workstation
