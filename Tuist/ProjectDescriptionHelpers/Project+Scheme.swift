import ProjectDescription

extension Scheme {

    public static func makeFonttasticScheme(
        schemeName: String,
        buildActionTargetReferences: [TargetReference],
        executableTargetReference: TargetReference?,
        arguments: Arguments? = .default(),
        storeKitConfigurationPath: Path? = nil
    ) -> Scheme {
        var runAction: RunAction?
        var profileAction: ProfileAction?
        if let executableTargetReference = executableTargetReference {
            runAction = .runAction(
                configuration: .debug,
                executable: executableTargetReference,
                arguments: arguments,
                options: .options(
                    language: nil,
                    storeKitConfigurationPath: storeKitConfigurationPath,
                    simulatedLocation: nil
                )
            )
            profileAction = .profileAction(
                configuration: .release,
                executable: executableTargetReference,
                arguments: arguments
            )
        }
        return Scheme(
            name: schemeName,
            shared: true,
            hidden: false,
            buildAction: .buildAction(
                targets: buildActionTargetReferences,
                preActions: [],
                postActions: [],
                runPostActionsOnFailure: false
            ),
            testAction: nil,
            runAction: runAction,
            archiveAction: .archiveAction(
                configuration: .release,
                revealArchiveInOrganizer: true,
                customArchiveName: nil,
                preActions: [],
                postActions: []
            ),
            profileAction: profileAction,
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    }
}
