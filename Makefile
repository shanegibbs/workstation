IMAGE=shanegibbs/workstation
USER=$(shell whoami)

build:
	docker build $(BUILD_ARGS) -t shanegibbs/workstation .

build-no-cache:
	$(MAKE) build BUILD_ARGS=--no-cache

build-static:
	docker build -f Dockerfile.static $(BUILD_ARGS) -t workstation:static .

run:
	mkdir -p "$(HOME)/workstation"
	echo $(USER) > "$(HOME)/workstation/username"
	docker run --name workstation --rm $(ARGS) \
		--net=host \
		--pid=host \
		--privileged \
		--tmpfs /run \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(HOME)/workstation:/workstation \
		-v $(HOME)/projects:/workstation/projects \
		-v $(HOME)/dev:/workstation/dev \
		-v $(HOME)/local:/workstation/local \
		$(IMAGE)

run-isolated:
	docker run --name workstation -t --rm --hostname workstation $(ARGS) \
		--net=host \
		--privileged \
		--tmpfs /run \
		$(IMAGE)

exec:
	docker exec -it workstation tmux -S /workstation/tmux.socket attach

attach:
	tmux -S ~/workstation/tmux.socket new -A -t workstation -s workstation

attach2:
	tmux -S ~/workstation/tmux.socket new -A -t workstation -s workstation2

run-simple:
	docker run --rm -it --name workstation --tmpfs /run --net=host --pid=host \
		$(IMAGE)

shell:
	docker run --rm -it --name workstation $(IMAGE) bash -l

stop:
	docker -f rm workstation

update-helm:
	# todo
