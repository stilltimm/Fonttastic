import ProjectDescription

public enum FonttasticConfiguration: Int, CaseIterable {

    case debug
    case beta
    case release

    // MARK: - Public Type Properties

    public static let allCases: [FonttasticConfiguration] = [
        .debug,
        .beta,
        .release
    ]

    // MARK: - Public Instance Properties

    public var displayName: String {
        switch self {
        case .debug:
            return "Debug"

        case .beta:
            return "Beta"

        case .release:
            return "Release"
        }
    }

    public var configurationName: ConfigurationName {
        switch self {
        case .debug:
            return .debug

        case .beta:
            return .beta

        case .release:
            return .release
        }
    }

    public var isDebug: Bool {
        switch self {
        case .debug:
            return true

        default:
            return false
        }
    }

    public var isBeta: Bool {
        switch self {
        case .beta:
            return true

        default:
            return false
        }
    }

    public var isRelease: Bool {
        switch self {
        case .release:
            return true

        default:
            return false
        }
    }
}

extension Scheme {

    // MARK: - Public Type Methods

    public static func makeFonttasticAppScheme(
        configuration: FonttasticConfiguration
    ) -> Scheme {
        var preBuildActions: [ExecutionAction] = []
        if configuration.isBeta {
            preBuildActions.append(
                ExecutionAction(
                    title: "Fix SPM",
                    scriptText: Constants.fixSPMScriptText,
                    target: .app()
                )
            )
        }
        return makeFonttasticScheme(
            schemeName: "\(ProjectConstants.appTargetName)-\(configuration.displayName)",
            configurationName: configuration.configurationName,
            buildActionTargetReferences: [.app()],
            buildPreActions: preBuildActions,
            executableTargetReference: .app(),
            includeAnalyzeAction: configuration.isDebug,
            includeArchiveAction: !configuration.isDebug
        )
    }

    public static func makeFonttasticToolsDebugScheme() -> Scheme {
        return makeFonttasticScheme(
            schemeName: ProjectConstants.toolsTargetName,
            configurationName: .debug,
            buildActionTargetReferences: [.tools()],
            buildPreActions: [],
            executableTargetReference: nil,
            includeAnalyzeAction: true,
            includeArchiveAction: false
        )
    }

    public static func makeFonttasticKeyboardDebugScheme() -> Scheme {
        return makeFonttasticScheme(
            schemeName: ProjectConstants.keyboardTargetName,
            configurationName: .debug,
            buildActionTargetReferences: [.app(), .keyboardExtension()],
            buildPreActions: [],
            executableTargetReference: nil,
            includeAnalyzeAction: true,
            includeArchiveAction: false
        )
    }

    // MARK: - Internal Type Methods

    static func makeFonttasticScheme(
        schemeName: String,
        configurationName: ConfigurationName,
        buildActionTargetReferences: [TargetReference],
        buildPreActions: [ExecutionAction],
        executableTargetReference: TargetReference?,
        includeAnalyzeAction: Bool,
        includeArchiveAction: Bool
    ) -> Scheme {
        let arguments: Arguments = .default()

        var runAction: RunAction?
        var profileAction: ProfileAction?
        if let executableTargetReference = executableTargetReference {
            runAction = .runAction(
                configuration: configurationName,
                executable: executableTargetReference,
                arguments: arguments,
                options: .options(
                    language: nil,
                    storeKitConfigurationPath: nil,
                    simulatedLocation: nil
                )
            )
            profileAction = .profileAction(
                configuration: configurationName,
                executable: executableTargetReference,
                arguments: arguments
            )
        }

        var analyzeAction: AnalyzeAction?
        if includeAnalyzeAction {
            analyzeAction = .analyzeAction(configuration: configurationName)
        }

        var archiveAction: ArchiveAction?
        if includeArchiveAction {
            archiveAction = .archiveAction(
                configuration: configurationName,
                revealArchiveInOrganizer: true,
                customArchiveName: nil,
                preActions: [],
                postActions: []
            )
        }

        return Scheme(
            name: schemeName,
            shared: true,
            hidden: false,
            buildAction: .buildAction(
                targets: buildActionTargetReferences,
                preActions: buildPreActions,
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
