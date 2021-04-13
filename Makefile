export

APP ?= root

.PHONY: check
check:
	mix deps.get
	mix credo

.PHONY: test
test:
	mix deps.get
	mix test

.PHONY: cover
cover:
	mix deps.get
	mix test --cover

.PHONY: shell
shell:
	mix deps.get
	iex -S mix

.PHONY: run
run:
	mix deps.get
	mix runner $(ARGS)