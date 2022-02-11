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
        [
            .package(url: "https://github.com/SVGKit/SVGKit", .upToNextMajor(from: "3.0.0")),
            .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "3.0.0")),
            .package(url: "https://github.com/weichsel/ZIPFoundation", .upToNextMajor(from: "0.9.0")),
            .package(url: "https://github.com/amplitude/Amplitude-iOS", .upToNextMajor(from: "8.7.0")),
            .package(url: "https://github.com/robb/Cartography", .upToNextMajor(from: "4.0.0")),
            .package(url: "https://github.com/RevenueCat/purchases-ios", .exact("4.0.0-beta.8")),
            .package(url: "https://github.com/bugsnag/bugsnag-cocoa", .upToNextMajor(from: "6.5.1"))
        ],
        baseSettings: .dependenciesBaseSettings(),
        targetSettings: targetSettings
    ),
    platforms: [.iOS]
)

extension Settings {

    public static func defaultSettings(
        base baseSettings: SettingsDictionary = SettingsDictionary(),
        debug debugSettings: SettingsDictionary = SettingsDictionary(),
        release releaseSettings: SettingsDictionary = SettingsDictionary()
    ) -> Settings {
        let debugConfiguration = Configuration.debug(name: .debug, settings: debugSettings)
        let releaseConfiguration = Configuration.release(name: .release, settings: releaseSettings)
        return .settings(
            base: baseSettings,
            configurations: [
                debugConfiguration,
                releaseConfiguration
            ]
        )
    }

    public static func dependenciesBaseSettings() -> Settings {
        var baseSettings = SettingsDictionary()
            .swiftVersion("5.5")
        baseSettings["IPHONEOS_DEPLOYMENT_TARGET"] = "14.0"
        return .defaultSettings(
            base: baseSettings
        )
    }
}
