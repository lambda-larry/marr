define package_install = 
	$(call ssh_exec,[ $$(dpkg --list | grep "^ii *$(1) " -c) != 0 ] || sudo apt-get install -y $(1))
endef

define package_remove = 
	$(call ssh_exec,[ $$(dpkg --list | grep "^ii *$(1) " -c) == 0 ] || sudo apt-get remove -y $(1))
endef

# Can by used as recipe dependency
package-install-%:
	@$(call foreach_context,$(context),$(call package_install,$(subst package-install-,,$@)))

# Can by used as recipe dependency
package-remove-%: 
	@$(call foreach_context,$(context),$(call package_remove,$(subst package-remove-,,$@)))
