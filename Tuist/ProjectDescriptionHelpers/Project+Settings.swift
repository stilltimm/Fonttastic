import Foundation
import ProjectDescription

extension SettingsDictionary {

    public func developmentTeam(_ developmentTeam: String) -> SettingsDictionary {
        var result = self
        result["DEVELOPMENT_TEAM"] = .string(developmentTeam)
        return result
    }

    public func activeCompilationConditions(_ conditions: String...) -> SettingsDictionary {
        var result = self
        result["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = .array(conditions)
        return result
    }

    public func gccPreprocessorDefinitions(_ conditions: String...) -> SettingsDictionary {
        var result = self
        result["GCC_PREPROCESSOR_DEFINITIONS"] = .array(conditions)
        return result
    }
}

extension Settings {

    fileprivate static func fonttasticSettings(
        base baseSettings: SettingsDictionary = SettingsDictionary(),
        debug debugSettings: SettingsDictionary,
        beta betaSettings: SettingsDictionary,
        release releaseSettings: SettingsDictionary
    ) -> Settings {
        let debugConfiguration = Configuration.debug(name: .debug, settings: debugSettings)
        let betaConfiguration = Configuration.release(name: .beta, settings: betaSettings)
        let releaseConfiguration = Configuration.release(name: .release, settings: releaseSettings)
        return .settings(
            base: baseSettings,
            configurations: [
                debugConfiguration,
                betaConfiguration,
                releaseConfiguration
            ]
        )
    }

    public static func projectSettings() -> Settings {
        let baseSettings = SettingsDictionary()
            .developmentTeam(ProjectConstants.developmentTeam)
            .swiftVersion("5.5")
            .appleGenericVersioningSystem()
        let debugSettings = SettingsDictionary()
            .activeCompilationConditions("DEBUG")
            .gccPreprocessorDefinitions("DEBUG=1")
        let betaSettings = SettingsDictionary()
            .swiftOptimizationLevel(.o)
            .swiftCompilationMode(.wholemodule)
            .activeCompilationConditions("BETA")
            .gccPreprocessorDefinitions("BETA=1")
        let releaseSettings = SettingsDictionary()
            .swiftOptimizationLevel(.o)
            .swiftCompilationMode(.wholemodule)
            .activeCompilationConditions("RELEASE")
            .gccPreprocessorDefinitions("RELEASE=1")
        return .fonttasticSettings(
            base: baseSettings,
            debug: debugSettings,
            beta: betaSettings,
            release: releaseSettings
        )
    }

    public static func appSettings() -> Settings {
        let debugSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "iPhone Developer",
                provisioningProfileSpecifier: "Fonttastic Development"
            )
        let betaAndReleaseSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "iPhone Distribution",
                provisioningProfileSpecifier: "Fonttastic AppStore"
            )
        return .fonttasticSettings(
            debug: debugSettings,
            beta: betaAndReleaseSettings,
            release: betaAndReleaseSettings
        )
    }

    public static func toolsSettings() -> Settings {
        let debugSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "Apple Development",
                provisioningProfileSpecifier: nil
            )
        let betaAndReleaseSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "Apple Distribution",
                provisioningProfileSpecifier: nil
            )
        return .fonttasticSettings(
            debug: debugSettings,
            beta: betaAndReleaseSettings,
            release: betaAndReleaseSettings
        )
    }

    public static func keyboardExtensionSettings() -> Settings {
        let debugSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "iPhone Developer",
                provisioningProfileSpecifier: "Fonttastic Keyboard Development"
            )
        let betaAndReleaseSettings = SettingsDictionary()
            .manualCodeSigning(
                identity: "iPhone Distribution",
                provisioningProfileSpecifier: "Fonttastic Keyboard AppStore"
            )
        return .fonttasticSettings(
            debug: debugSettings,
            beta: betaAndReleaseSettings,
            release: betaAndReleaseSettings
        )
    }
}

extension ConfigurationName {

    static let beta: ConfigurationName = "Beta"
}
