fmt:
	@shfmt --version
	@find . -maxdepth 3 -name '*.sh' | while read -r src; do shfmt -i 4 -w -p "$$src"; done
	@find . -maxdepth 3 -name '*.zsh' | while read -r src; do shfmt -i 4 -w "$$src"; done;

test:
	./scripts/test

ci:
	./scripts/test
