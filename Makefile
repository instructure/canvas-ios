bootstrap: ## Local developer environment setup
	@git config commit.template .gitcommit
	@brew config && brew update
	@brew bundle
	@bundle install

bootstrap-ci: ## CI environment setup
	@brew install "xcodegen"
	@bundle install

sync: ## xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen

sync-ci: ## CI specific xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen --spec "project-ci.yml"
