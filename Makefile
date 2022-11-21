provision: ##
	@brew config && brew update
	@brew bundle
	@gem install cocoapods
	@yarn global add react-native-cli --prefix /usr/local

provision-ci:
	@brew install "xcodegen"

gen: ## Generate xproj for Core, TestsFoundation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd TestsFoundation; xcodegen