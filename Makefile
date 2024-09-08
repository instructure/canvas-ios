provision: ## Environment setup
	@git config commit.template .gitcommit
	@brew config && brew update
	@brew bundle
	@yarn global add react-native-cli --prefix ~/.local

provision-ci: ## CI environment setup
	@brew install "xcodegen"

sync: ## xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen

sync-ci: ## CI specific xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen --spec "project-ci.yml"

unexport INFOPLIST_FILE
unexport INFOPLIST_PATH
pod: ## runs pod install without some environment variables to fix code signing issues
	@pod install