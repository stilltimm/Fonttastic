// swift-tools-version:5.5
import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: ProjectConstants.projectName,
    organizationName: ProjectConstants.organizationName,
    options: [
        .textSettings(
            usesTabs: false,
            indentWidth: 4,
            tabWidth: 4,
            wrapsLines: false
        )
    ],
    settings: .projectSettings(),
    targets: [
        .makeFonttasticTarget(
            name: ProjectConstants.appTargetName,
            product: .app,
            bundleId: ProjectConstants.appBundleIdentifier,
            hasEntitlements: true,
            hasHeaders: false,
            dependencies: .appDependencies(),
            settings: .appSettings()
        ),
        .makeFonttasticTarget(
            name: ProjectConstants.toolsTargetName,
            product: .framework,
            bundleId: ProjectConstants.toolsBundleIdentifier,
            hasEntitlements: false,
            hasHeaders: true,
            dependencies: .toolsDependencies(),
            settings: .toolsSettings()
        ),
        .makeFonttasticTarget(
            name: ProjectConstants.keyboardTargetName,
            product: .appExtension,
            bundleId: ProjectConstants.keyboardBundleIdentifier,
            hasEntitlements: true,
            hasHeaders: false,
            dependencies: .keyboardExtensionDependencies(),
            settings: .keyboardExtensionSettings()
        )
    ],
    schemes: [
        FonttasticConfiguration.allCases.map { Scheme.makeFonttasticAppScheme(configuration: $0) },
        [Scheme.makeFonttasticToolsDebugScheme()],
        [Scheme.makeFonttasticKeyboardDebugScheme()]
    ].flatMap { $0 },
    resourceSynthesizers: [
        .assets(),
        .strings()
    ]
)
