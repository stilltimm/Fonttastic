import Foundation
import ProjectDescription

extension SettingsDictionary {

    public func developmentTeam(_ developmentTeam: String) -> SettingsDictionary {
        var result = self
        result["DEVELOPMENT_TEAM"] = .string(developmentTeam)
        return result
    }
}

extension Settings {

    public static func projectSettings() -> Settings {
        return .settings(
            base: SettingsDictionary()
                .developmentTeam(ProjectConstants.developmentTeam)
                .swiftVersion("5.5")
                .currentProjectVersion(ProjectConstants.currentAppVersion),
            debug: SettingsDictionary()
                .swiftOptimizationLevel(.oNone),
            release: SettingsDictionary()
                .swiftOptimizationLevel(.o)
                .swiftCompilationMode(.wholemodule)
        )
    }

    public static func appSettings() -> Settings {
        return .settings(
            debug: SettingsDictionary()
                .manualCodeSigning(
                    identity: "iPhone Developer",
                    provisioningProfileSpecifier: "Fonttastic Development"
                ),
            release: SettingsDictionary()
                .manualCodeSigning(
                    identity: "iPhone Distribution",
                    provisioningProfileSpecifier: "Fonttastic AppStore"
                )
        )
    }

    public static func toolsSettings() -> Settings {
        return .settings(
            debug: SettingsDictionary()
                .manualCodeSigning(
                    identity: "Apple Development",
                    provisioningProfileSpecifier: nil
                ),
            release: SettingsDictionary()
                .manualCodeSigning(
                    identity: "Apple Distribution",
                    provisioningProfileSpecifier: nil
                )
        )
    }

    public static func keyboardExtensionSettings() -> Settings {
        return .settings(
            debug: SettingsDictionary()
                .manualCodeSigning(
                    identity: "iPhone Developer",
                    provisioningProfileSpecifier: "Fonttastic Keyboard Development"
                ),
            release: SettingsDictionary()
                .manualCodeSigning(
                    identity: "iPhone Distribution",
                    provisioningProfileSpecifier: "Fonttastic Keyboard AppStore"
                )
        )
    }
}
