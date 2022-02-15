[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)
[![Publish Beta & Release](https://github.com/stilltimm/Fonttastic/actions/workflows/publish-beta-and-release.yml/badge.svg?branch=develop)](https://github.com/stilltimm/Fonttastic/actions/workflows/publish-beta-and-release.yml)

# Fonttastic
This is Fonttastic iOS app repository. It is an app that implements custom iOS keyboard with a canvas where you can write any text with custom fonts.

## Setup Guide
### 1. Clone Repo & Setup Xcode Project
Firstly, to setup the project, please execute following commands at your Terminal:
```
git clone https://github.com/stilltimm/Fonttastic.git
cd Fonttastic
git lfs install
./generate-project.sh
open ./Fonttastic.xcworkspace
```
It will clone the repo to your working directory, install dependencies, setup Xcode project and open it.

### 2. Add Environment Configuration
Secondly, in order for app to work, you should setup [RevenueCat](https://www.revenuecat.com), [Amplitude](https://amplitude.com) and [Bugsnag](https://www.bugsnag.com) accounts, get API keys from them and then add the configuration file `Environment.plist` at path `./FonttasticTools/Resources/Environment.plist` (it is ignored by git for security reasons). The contents of the file should be this:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PURCHASES_API_KEY</key>
	<string>YOUR_PURCHASES_API_KEY</string>
	<key>AMPLITUDE_API_KEY</key>
	<string>YOUR_AMPLITUDE_API_KEY</string>
	<key>BUGSNAG_API_KEY</key>
	<string>YOUR_BUGSNAG_API_KEY</string>
</dict>
</plist>
```
It is needed for configuring external SDK's.

### 3. Buld & Run
Finally, select scheme **Fonttastic** from Xcode's status bar dropdown menu and then Build & Run.
