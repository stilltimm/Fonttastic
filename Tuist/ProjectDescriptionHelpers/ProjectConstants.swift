import Foundation
import ProjectDescription

public enum ProjectConstants {

    // MARK: - Public Type Properties

    public static let developmentTeam: String = "88Q8M3ZBSJ"
    public static let organizationName: String = "com.romandegtyarev"
    public static let projectName: String = "Fonttastic"

    public static let appTargetName: String = "Fonttastic"
    public static let toolsTargetName: String = "FonttasticTools"
    public static let keyboardTargetName: String = "FonttasticKeyboard"

    public static let currentProjectVersion: String = Environment[
        dynamicMember: "projectVersion"
    ].getString(default: "1")

    public static let appBundleIdentifier: String = "\(organizationName).fonttastic"
    public static let toolsBundleIdentifier: String = "\(organizationName).fonttasticTools"
    public static let keyboardBundleIdentifier: String = "\(organizationName).fonttastic.fonttasticKeyboard"
}
