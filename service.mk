define service_disable =
	$(call ssh_exec,[ $$(systemctl is-enable $(1)) == "disabled" ] || sudo systemctl disable $(1))
endef
define service_enable =
	$(call ssh_exec,[ $$(systemctl is-enable $(1)) == "enabled" ] || sudo systemctl enable $(1))
endef
define service_start =
	$(call ssh_exec,[ $$(systemctl is-active $(1)) == "active" ] || sudo systemctl start $(1))
endef
define service_stop =
	$(call ssh_exec,[ $$(systemctl is-active $(1)) == "inactive" ] || sudo systemctl stop $(1))
endef





service-enable-%:
	@$(call foreach_context,$(context),$(call service_enable,$(subst service-enable-,,$@)))

service-disable-%:
	@$(call foreach_context,$(context),$(call service_disable,$(subst service-disable-,,$@)))

service-start-%:
	@$(call foreach_context,$(context),$(call service_start,$(subst service-start-,,$@)))

service-stop-%:
	@$(call foreach_context,$(context),$(call service_stop,$(subst service-stop-,,$@)))
