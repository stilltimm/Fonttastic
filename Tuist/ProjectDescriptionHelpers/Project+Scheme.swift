import ProjectDescription

extension Scheme {

    // MARK: - Public Type Methods

    public static func makeFonttasticAppScheme() -> Scheme {
        return makeFonttasticScheme(
            schemeName: ProjectConstants.appTargetName,
            buildActionTargetReferences: [.app()],
            executableTargetReference: .app()
        )
    }

    public static func makeFonttasticToolsDebugScheme() -> Scheme {
        return makeFonttasticScheme(
            schemeName: ProjectConstants.toolsTargetName,
            buildActionTargetReferences: [.tools()],
            executableTargetReference: nil
        )
    }

    public static func makeFonttasticKeyboardDebugScheme() -> Scheme {
        return makeFonttasticScheme(
            schemeName: ProjectConstants.keyboardTargetName,
            buildActionTargetReferences: [.app(), .keyboardExtension()],
            executableTargetReference: nil
        )
    }

    // MARK: - Internal Type Methods

    static func makeFonttasticScheme(
        schemeName: String,
        buildActionTargetReferences: [TargetReference],
        executableTargetReference: TargetReference?
    ) -> Scheme {
        let arguments: Arguments = .default()

        var runAction: RunAction?
        var profileAction: ProfileAction?
        if let executableTargetReference = executableTargetReference {
            runAction = .runAction(
                configuration: .debug,
                executable: executableTargetReference,
                arguments: arguments,
                options: .options(
                    language: nil,
                    storeKitConfigurationPath: nil,
                    simulatedLocation: nil
                )
            )
            profileAction = .profileAction(
                configuration: .release,
                executable: executableTargetReference,
                arguments: arguments
            )
        }

        let analyzeAction: AnalyzeAction = .analyzeAction(configuration: .debug)
        let archiveAction: ArchiveAction = .archiveAction(
            configuration: .release,
            revealArchiveInOrganizer: true,
            customArchiveName: nil,
            preActions: [],
            postActions: []
        )

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
            archiveAction: archiveAction,
            profileAction: profileAction,
            analyzeAction: analyzeAction
        )
    }
}

private enum Constants {

    static let fixSPMScriptText: String = """
    if [ -d "${SYMROOT}/Release${EFFECTIVE_PLATFORM_NAME}/" ] && [ "${SYMROOT}/Release${EFFECTIVE_PLATFORM_NAME}/" != "${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/" ]
    then
    cp -f -R "${SYMROOT}/Release${EFFECTIVE_PLATFORM_NAME}/" "${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/"
    fi
    """
}
