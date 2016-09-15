fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios setup_dev
```
fastlane ios setup_dev
```
Install development certs and checkout carthage deps
### ios commit
```
fastlane ios commit
```
Build for development and run unit tests
### ios test
```
fastlane ios test
```
Run app tests on a simulator. Run commit lane first
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios build_for_device
```
fastlane ios build_for_device
```
Build app for device. Run commit lane first
### ios appstore
```
fastlane ios appstore
```
Deploy a new version to the App Store
### ios coverage
```
fastlane ios coverage
```
Generate code coverage report. Run commit lane first

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).