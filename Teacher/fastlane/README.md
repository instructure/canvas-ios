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
Run app tests on a simulator
### ios build_for_device
```
fastlane ios build_for_device
```
Build app for device. Run commit lane first
### ios coverage
```
fastlane ios coverage
```
Generate code coverage report. Run commit lane first

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).