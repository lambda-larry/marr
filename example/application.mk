
setup-dev-application: context := home-lab/*/*
setup-dev-application: package-install-nginx
setup-dev-application: package-install-docker.io
setup-dev-application: package-install-docker-compose
setup-dev-application: service-start-nginx


# teardown: 47 sec for job control (DEV only)
# setup: 45 sec for job control (DEV only)
# teardown: 1 min 8 sec without job control (DEV only)
# setup: 1 min 8 sec without job control (DEV only)
#
# teardown: 47 sec for job control (DEV and PROD)
# setup: 1 min  for job control (DEV and PROD)
# teardown: ?? sec without job control (DEV and PROD)
# setup: ?? sec without job control (DEV and PROD)

.PHONY: context-test
context-test:
	@$(call foreach_context,$(context),$(call ssh_exec,hostname))
