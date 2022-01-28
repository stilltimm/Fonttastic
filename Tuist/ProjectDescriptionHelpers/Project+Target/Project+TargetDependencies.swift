import ProjectDescription

extension Array where Element == TargetDependency {

    public static func toolsDependencies() -> [TargetDependency] {
        return [
            .external(name: "Cartography"),
            .external(name: "ZIPFoundation"),
            .external(name: "RevenueCat"),
            .external(name: "Amplitude"),
            .external(name: "KeychainAccess"),
            .external(name: "Bugsnag")
        ]
    }

    public static func keyboardExtensionDependencies() -> [TargetDependency] {
        return [
            .target(name: "FonttasticTools")
        ]
    }

    public static func appDependencies() -> [TargetDependency] {
        return [
            .target(name: "FonttasticTools"),
            .target(name: "FonttasticKeyboard"),
            .external(name: "SVGKit")
        ]
    }
}
