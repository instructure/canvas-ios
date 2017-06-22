fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>
# Available Actions
## iOS
### ios pull_frameworks
```
fastlane ios pull_frameworks
```
build frameworks for pull request
### ios pull_canvas
```
fastlane ios pull_canvas
```
build canvas for pull request
### ios beta_canvas
```
fastlane ios beta_canvas
```
build Canvas.app and submit to iTunes Connect
### ios pull_teacher
```
fastlane ios pull_teacher
```

### ios beta_teacher
```
fastlane ios beta_teacher
```
build Teacher.app and submit to iTunes Connect
### ios pull_parent
```
fastlane ios pull_parent
```
build parent for pull request
### ios beta_parent
```
fastlane ios beta_parent
```
build Parent.app and submit to iTunes Connect
### ios test_parent
```
fastlane ios test_parent
```
Test Parent.app
### ios deps
```
fastlane ios deps
```
Update carthage and cocoapods dependencies
### ios build_earlgrey_parent
```
fastlane ios build_earlgrey_parent
```
Parent.app EarlGrey build-for-testing
### ios test_earlgrey_parent
```
fastlane ios test_earlgrey_parent
```
Parent.app EarlGrey test-without-building.
Requires fbsimctl

brew tap facebook/fb
brew install fbsimctl --HEAD
### ios seed_teacher
```
fastlane ios seed_teacher
```
Seed data into Canvas LMS for testing.
### ios test_earlgrey_teacher
```
fastlane ios test_earlgrey_teacher
```
Test teacher app with Earl Grey,
### ios bluepill_teacher
```
fastlane ios bluepill_teacher
```
Test teacher app with Earl Grey,

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
