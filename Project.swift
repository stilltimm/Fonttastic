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
        .makeFonttasticAppTarget(),
        .makeFonttasticToolsTarget(),
        .makeFonttasticKeyboardTarget()
    ],
    schemes: [
        .makeFonttasticAppScheme(),
        .makeFonttasticToolsDebugScheme(),
        .makeFonttasticKeyboardDebugScheme()
    ],
    resourceSynthesizers: [
        .assets(),
        .strings()
    ]
)
