PREFIX   ?= /usr/local
BINDIR    = $(PREFIX)/bin
MANDIR    = $(PREFIX)/share/man/man1
COMPDIR_BASH = $(PREFIX)/share/bash-completion/completions
COMPDIR_ZSH  = $(PREFIX)/share/zsh/site-functions
COMPDIR_FISH = $(PREFIX)/share/fish/vendor_completions.d

.PHONY: install uninstall deps deps-remote test lint fmt check help

install:
	@mkdir -p $(BINDIR) $(MANDIR)
	@cp bin/uft $(BINDIR)/uft
	@chmod 755 $(BINDIR)/uft
	@cp man/uft.1 $(MANDIR)/uft.1
	@chmod 644 $(MANDIR)/uft.1
	@mkdir -p $(COMPDIR_BASH) $(COMPDIR_ZSH) $(COMPDIR_FISH)
	@cp completions/uft.bash $(COMPDIR_BASH)/uft 2>/dev/null || true
	@cp completions/uft.zsh  $(COMPDIR_ZSH)/_uft 2>/dev/null || true
	@cp completions/uft.fish $(COMPDIR_FISH)/uft.fish 2>/dev/null || true
	@echo "installed uft to $(BINDIR)/uft"

uninstall:
	@rm -f $(BINDIR)/uft
	@rm -f $(MANDIR)/uft.1
	@rm -f $(COMPDIR_BASH)/uft
	@rm -f $(COMPDIR_ZSH)/_uft
	@rm -f $(COMPDIR_FISH)/uft.fish
	@echo "removed uft from $(BINDIR)"

test:
	@command -v bats >/dev/null 2>&1 || { echo "install bats-core first: brew install bats-core"; exit 1; }
	bats tests/

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "install shellcheck: brew install shellcheck"; exit 1; }
	shellcheck bin/uft

fmt:
	@command -v shfmt >/dev/null 2>&1 || { echo "install shfmt: brew install shfmt"; exit 1; }
	shfmt -i 4 -ci -w bin/uft

deps:
	@echo "installing optional dependencies (local)..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install lz4 pv zstd 2>/dev/null || true; \
		echo "done (homebrew)"; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get install -y lz4 pv zstd 2>/dev/null || true; \
		echo "done (apt)"; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y lz4 pv zstd 2>/dev/null || true; \
		echo "done (yum)"; \
	else \
		echo "unknown package manager — install lz4, pv, zstd manually"; \
	fi

deps-dev:
	@echo "installing dev dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install shellcheck bats-core shfmt 2>/dev/null || true; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get install -y shellcheck bats shfmt 2>/dev/null || true; \
	fi
	@echo "done"

check: lint test

help:
	@echo "targets:"
	@echo "  install    install uft to $(PREFIX)"
	@echo "  uninstall  remove uft"
	@echo "  test       run bats tests"
	@echo "  lint       run shellcheck"
	@echo "  fmt        format with shfmt"
	@echo "  deps       install optional tools (lz4, pv, zstd)"
	@echo "  deps-dev   install dev tools (shellcheck, bats, shfmt)"
	@echo "  check      lint + test"
