// swift-tools-version:5.5
import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Fonttastic",
    organizationName: "com.romandegtyarev",
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
            name: "Fonttastic",
            product: .app,
            bundleId: "com.romandegtyarev.fonttastic",
            hasEntitlements: true,
            hasHeaders: false,
            dependencies: .appDependencies(),
            settings: .appSettings()
        ),
        .makeFonttasticTarget(
            name: "FonttasticTools",
            product: .framework,
            bundleId: "com.romandegtyarev.fonttasticTools",
            hasEntitlements: false,
            hasHeaders: true,
            dependencies: .toolsDependencies(),
            settings: .toolsSettings()
        ),
        .makeFonttasticTarget(
            name: "FonttasticKeyboard",
            product: .appExtension,
            bundleId: "com.romandegtyarev.fonttastic.fonttasticKeyboard",
            hasEntitlements: true,
            hasHeaders: false,
            dependencies: .keyboardExtensionDependencies(),
            settings: .keyboardExtensionSettings()
        )
    ],
    schemes: [
        .makeFonttasticScheme(
            schemeName: "Fonttastic",
            buildActionTargetReferences: [.app()],
            executableTargetReference: .app(),
            storeKitConfigurationPath: "Fonttastic/SupportFiles/Configuration.storeKit"
        ),
        .makeFonttasticScheme(
            schemeName: "FonttasticTools",
            buildActionTargetReferences: [.tools()],
            executableTargetReference: nil
        ),
        .makeFonttasticScheme(
            schemeName: "FonttasticKeyboard",
            buildActionTargetReferences: [.app(), .keyboardExtension()],
            executableTargetReference: .keyboardExtension()
        )
    ],
    resourceSynthesizers: [
        .assets(),
        .strings()
    ]
)
