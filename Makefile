provision: ## Environment setup
	@git config commit.template .gitcommit
	@brew config && brew update
	@brew bundle
	@yarn global add react-native-cli --prefix ~/.local

provision-ci: ## CI environment setup
	@brew install "xcodegen"

sync: ## Dependency installation 
	@make gen
	@cd rn/Teacher; yarn build

gen: ## xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd TestsFoundation; xcodegen