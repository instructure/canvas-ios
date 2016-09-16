fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios run_match_development
```
fastlane ios run_match_development
```
Runs match to install dev certs
### ios setup_dev
```
fastlane ios setup_dev
```
Install development certs and checkout carthage deps
### ios commit
```
fastlane ios commit
```
Builds after each commit to make sure the app can be built and run correctly
### ios feature
```
fastlane ios feature
```
Builds after each commit to make sure the app can be built and run correctly
### ios release
```
fastlane ios release
```
Submit a new Beta Build to Apple TestFlight
### ios lint
```
fastlane ios lint
```
Checks for deployment target changes
### ios beta_patch
```
fastlane ios beta_patch
```
Submit a new Beta Build to Apple TestFlight
### ios beta_minor
```
fastlane ios beta_minor
```
Submit a new Beta Build to Apple TestFlight
### ios beta_major
```
fastlane ios beta_major
```
Submit a new Beta Build to Apple TestFlight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).