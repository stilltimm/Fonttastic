// swift-tools-version:5.5
import ProjectDescription

let config = Config(
    compatibleXcodeVersions: ["13.0", "13.1"],
    swiftVersion: "5.5.0",
    generationOptions: [
        .developmentRegion("ru")
    ]
)
