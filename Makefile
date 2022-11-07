provision: ##
	@brew config && brew update
	@brew bundle
	@gem install cocoapods
	@yarn global add react-native-cli --prefix /usr/local

gen: ## Generate xproj for Core, TestsFoundation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd TestsFoundation; xcodegen