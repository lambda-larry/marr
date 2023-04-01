# The makefile to handle context parameter


define source_context = 
	CONTEXT="$(1)"

	DIR_STACK=()
	VAR_FILES=()

	# Build the stack
	while [ "$$CONTEXT" != . ]; do
		DIR_STACK+=("$$CONTEXT")
		CONTEXT=$$(dirname "$$CONTEXT")
	done

	SHOPT_NULLGLOB="$$(shopt -p nullglob || true)"
	shopt -s nullglob
	while [ "$${#DIR_STACK[@]}" != 0 ]; do
		VAR_FILES+=("$${DIR_STACK[-1]}"/*.sh)
		unset -v 'DIR_STACK[-1]'
	done
	eval "$$SHOPT_NULLGLOB"

	# eval "$$(cat "$${VAR_FILES[@]}")"
	eval "$$(cat <(echo) "$${VAR_FILES[@]}")"
endef

define foreach_context =
	{
		$(foreach ctx,$(wildcard $(1)/),( :; $(call source_context,$(ctx)); $(2)) &)
	}
endef
