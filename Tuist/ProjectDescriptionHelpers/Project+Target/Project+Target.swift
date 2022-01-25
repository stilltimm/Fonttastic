import ProjectDescription

extension Target {

    public static func makeFonttasticTarget(
        name: String,
        product: Product,
        bundleId: String,
        hasEntitlements: Bool,
        hasHeaders: Bool,
        dependencies: [TargetDependency],
        settings: Settings
    ) -> Target {
        var entitlementsPath: Path?
        if hasEntitlements {
            entitlementsPath = "\(name)/SupportFiles/\(name).entitlements"
        }

        var headers: Headers?
        if hasHeaders {
            headers = Headers(
                public: "\(name)/Headers/Public/**",
                private: "\(name)/Headers/Private/**",
                project: nil
            )
        }

        return Target(
            name: name,
            platform: .iOS,
            product: product,
            bundleId: bundleId,
            deploymentTarget: .iOS_14_iphone(),
            infoPlist: .file(path: "\(name)/SupportFiles/Info.plist"),
            sources: ["\(name)/Sources/**"],
            resources: ["\(name)/Resources/**"],
            headers: headers,
            entitlements: entitlementsPath,
            scripts: [.tuistLint()],
            dependencies: dependencies,
            settings: settings
        )
    }
}
