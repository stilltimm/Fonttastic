import ProjectDescription

extension Target {

    // MARK: - Public Type Properties

    public static func makeFonttasticAppTarget() -> Target {
        return makeFonttasticTarget(
            name: ProjectConstants.appTargetName,
            product: .app,
            bundleId: ProjectConstants.appBundleIdentifier,
            hasResources: true,
            hasHeaders: false,
            hasEntitlements: true,
            scripts: [.tuistLint()],
            dependencies: .appDependencies(),
            settings: .appSettings()
        )
    }

    public static func makeFonttasticToolsTarget() -> Target {
        return makeFonttasticTarget(
            name: ProjectConstants.toolsTargetName,
            product: .framework,
            bundleId: ProjectConstants.toolsBundleIdentifier,
            hasResources: true,
            hasHeaders: true,
            hasEntitlements: false,
            scripts: [.fixSPM(), .tuistLint()],
            dependencies: .toolsDependencies(),
            settings: .toolsSettings()
        )
    }

    public static func makeFonttasticKeyboardTarget() -> Target {
        return makeFonttasticTarget(
            name: ProjectConstants.keyboardTargetName,
            product: .appExtension,
            bundleId: ProjectConstants.keyboardBundleIdentifier,
            hasResources: false,
            hasHeaders: false,
            hasEntitlements: true,
            scripts: [.tuistLint()],
            dependencies: .keyboardExtensionDependencies(),
            settings: .keyboardExtensionSettings()
        )
    }

    // MARK: - Private Type Properties

    private static func makeFonttasticTarget(
        name: String,
        product: Product,
        bundleId: String,
        hasResources: Bool,
        hasHeaders: Bool,
        hasEntitlements: Bool,
        scripts: [TargetScript],
        dependencies: [TargetDependency],
        settings: Settings
    ) -> Target {
        var resources: ResourceFileElements?
        if hasResources {
            resources = ["\(name)/Resources/**"]
        }

        var headers: Headers?
        if hasHeaders {
            headers = .headers(
                public: "\(name)/Headers/Public/**",
                private: "\(name)/Headers/Private/**",
                project: nil,
                exclusionRule: .publicExcludesPrivateAndProject
            )
        }

        var entitlementsPath: Path?
        if hasEntitlements {
            entitlementsPath = "\(name)/SupportFiles/\(name).entitlements"
        }

        return Target(
            name: name,
            platform: .iOS,
            product: product,
            bundleId: bundleId,
            deploymentTarget: .iOS_14_iphone(),
            infoPlist: .file(path: "\(name)/SupportFiles/Info.plist"),
            sources: ["\(name)/Sources/**"],
            resources: resources,
            headers: headers,
            entitlements: entitlementsPath,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings
        )
    }
}
