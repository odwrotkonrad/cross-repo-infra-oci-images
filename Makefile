##[>] 🤖🤖
#[what] Project's Makefile
SHELL := zsh
.SHELLFLAGS := -c
export PATH := $(CURDIR)/ci/zsh/scripts:$(PATH)

COMMANDS := che-install generic-setup image-build-ci-linux image-build-che

.PHONY: $(COMMANDS)

-include shared/generic/make/generic.mk

##[>] Setup [genai-include]
#[what] install the latest released che into ~/.local/bin, only when the one on PATH is older
che-install:
	@curl -fsSL https://konradodwrot.gitlab.io/go-modules/che-install.sh | sh -s -- --skip-if-present-is-newer

#[what] render the generic consumer payload (generic.mk, lefthook.yml, shared/generic/) at the pinned CENTRALIZED_ASSETS_GENERIC_REF
generic-setup:
	@$${CHE_BIN:-che} render-templates --profiles=genericSetup

shared/generic/make/generic.mk: generic-setup
##[<] Setup

##[>] Images [genai-include]
#[what] build ci-linux:local for the host arch
image-build-ci-linux:
	@image-build-ci-linux.zsh

#[what] build che:local (distroless, che only) for the host arch at the .repo/upstream.env che pin
image-build-che:
	@image-build-che.zsh
##[<] Images
##[<] 🤖🤖
