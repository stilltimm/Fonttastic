import Foundation

public enum ProjectConstants {

    // MARK: - Public Type Properties

    public static let developmentTeam: String = "88Q8M3ZBSJ"
    public static let organizationName: String = "com.romandegtyarev"
    public static let projectName: String = "Fonttastic"

    public static let appTargetName: String = "Fonttastic"
    public static let toolsTargetName: String = "FonttasticTools"
    public static let keyboardTargetName: String = "FonttasticKeyboard"

    public static let currentProjectVersion: String = {
        let versionFileURL = URL(fileURLWithPath: "./.current-project-version")
        do {
            return try String(contentsOf: versionFileURL, encoding: .utf8)
        } catch {
            print(error)
        }
        return "1"
    }()

    public static let appBundleIdentifier: String = "\(organizationName).fonttastic"
    public static let toolsBundleIdentifier: String = "\(organizationName).fonttasticTools"
    public static let keyboardBundleIdentifier: String = "\(organizationName).fonttastic.fonttasticKeyboard"
}
