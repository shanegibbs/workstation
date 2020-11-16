IMAGE=shanegibbs/workstation
USER=$(shell whoami)
DOCKER_ARGS=--name workstation -t --rm --hostname workstation \
	    --cap-add NET_ADMIN \
	    --cap-add SYS_CHROOT \
	    --cap-add SYS_PTRACE \
	    --cap-add SYS_RESOURCE \
	    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	    --tmpfs /run \
	    --tmpfs /tmp
DIND_DOCKER_ARGS=--name workstation -t --rm --hostname workstation \
		 --privileged \
		 --tmpfs /run \
		 --tmpfs /tmp \
		 -v $(shell pwd)/docker-fs:/var/lib/docker

# NET_ADMIN so we can do iptables
# SYS_CHROOT so we can chroot
# SYS_PTRACE so we can packet trace
# SYS_RESOURCE so we can set oomadj scores
# SYS_ADMIN so we can namespace

# need priv to run docker as it uses the kernel keyring which isn't namespaces

build:
	docker build $(BUILD_ARGS) -t shanegibbs/workstation .

build-no-cache:
	$(MAKE) build BUILD_ARGS=--no-cache

build-static:
	docker build -f Dockerfile.static $(BUILD_ARGS) -t workstation:static .

run:
	mkdir -p "$(HOME)/workstation"
	echo $(USER) > "$(HOME)/workstation/username"
	docker run $(DOCKER_ARGS) \
		--shm-size 2g \
		$(IMAGE)
		# -v /var/run/docker.sock:/var/run/docker.sock \
		# -v $(HOME)/workstation:/workstation \
		# -v $(HOME)/projects:/workstation/projects \
		# -v $(HOME)/dev:/workstation/dev \
		# -v $(HOME)/local:/workstation/local \

vnc:
	VNC_PASSWORD=workstation vncviewer 172.17.0.2:1 

run-isolated:
	docker run $(DIND_DOCKER_ARGS) --net=host $(IMAGE)

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
	docker rm -f workstation

update-helm:
	# todo
