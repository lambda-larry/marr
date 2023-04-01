define docker_image_pull = 
	$(call ssh_exec,sudo docker image pull $(1))
endef

define docker_image_rm = 
	$(call ssh_exec,sudo docker image rm $(1))
endef

define docker_compose_up =
	$(call ssh_exec,sudo docker-compose up -f $(1))
endef

define docker_compose_down =
	$(call ssh_exec,sudo docker-compose down -f $(1))
endef
