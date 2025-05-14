provision: ## Environment setup
	@git config commit.template .gitcommit
	@brew config && brew update
	@brew bundle
	@$(MAKE) generate-placeholder-plist-files

provision-ci: ## CI environment setup
	@brew install "xcodegen"
	@$(MAKE) generate-placeholder-plist-files

sync: ## xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen

sync-ci: ## CI specific xproj file generation
	@echo 🟡 Running xcodegen
	@cd Core; xcodegen
	@cd Student; xcodegen --spec "project-ci.yml"

generate-placeholder-plist-files:
	@$(MAKE) generate-placeholder-plist-file PLIST_PATH=./Student/Student/GoogleService-Info.plist
	@$(MAKE) generate-placeholder-plist-file PLIST_PATH=./Student/SubmitAssignment/GoogleService-Info.plist
	@$(MAKE) generate-placeholder-plist-file PLIST_PATH=./Teacher/Teacher/GoogleService-Info.plist
	@$(MAKE) generate-placeholder-plist-file PLIST_PATH=./Parent/Parent/GoogleService-Info.plist

generate-placeholder-plist-file:
	@echo "Generating empty GoogleService-Info.plist file at: $${PLIST_PATH}"
	@printf '%s\n' \
	'<?xml version="1.0" encoding="UTF-8"?>' \
	'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	'<plist version="1.0">' \
	'<dict/>' \
	'</plist>' > "$${PLIST_PATH}"