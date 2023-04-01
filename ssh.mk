define ssh_exec = 
	$(call source_context,$(context))
	[ -n "$$host" ]
	ssh "$$user"@"$$host" ':; $(1)'
endef


define ssh_scp =
	$(call source_context,$(context))
	[ -n "$$host" ]
	scp $(if $(3),-r) "$(1)" "$$user"@"$$host:$(2)"
endef


ssh-cmd:
	@$(call foreach_context,$(context),$(call ssh_exec,$(cmd)))

run-custom-cmd: ssh-cmd

ssh-scp:
	@$(call ssh_scp,$(src),$(dest),$(recursive))

ssh-shell:
	@$(call source_context,$(context))
	[ -n "$$host" ]
	ssh "$$user"@"$$host"
