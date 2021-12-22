// swift-tools-version:5.5
import ProjectDescription

private let targetNames: [String] = [
    "SVGKit",
    "KeychainAccess",
    "ZIPFoundation",
    "Amplitude",
    "Cartography",
    "RevenueCat",
    "Bugsnag"
]
let targetSettingsDictionary: SettingsDictionary = [
    "IPHONEOS_DEPLOYMENT_TARGET": "14.0"
]
let targetSettings = Dictionary<String, SettingsDictionary>(
    uniqueKeysWithValues: targetNames.map { targetName -> (String, SettingsDictionary) in
        return (targetName, targetSettingsDictionary)
    }
)

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [.package(url: "https://github.com/SVGKit/SVGKit", .upToNextMajor(from: "3.0.0")),
         .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "3.0.0")),
         .package(url: "https://github.com/weichsel/ZIPFoundation", .upToNextMajor(from: "0.9.0")),
         .package(url: "https://github.com/amplitude/Amplitude-iOS", .upToNextMajor(from: "8.7.0")),
         .package(url: "https://github.com/robb/Cartography", .upToNextMajor(from: "4.0.0")),
         .package(url: "https://github.com/RevenueCat/purchases-ios", .exact("4.0.0-beta.8")),
         .package(url: "https://github.com/bugsnag/bugsnag-cocoa", .upToNextMajor(from: "6.5.1"))
        ],
        targetSettings: targetSettings
    ),
    platforms: [.iOS]
)

