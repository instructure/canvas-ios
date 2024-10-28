provision: ## Environment setup
	@git config commit.template .gitcommit
	@brew config && brew update
	@brew bundle

provision-ci: ## CI environment setup
	@brew install "xcodegen"

sync: ## xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen

sync-ci: ## CI specific xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen --spec "project.yml"
