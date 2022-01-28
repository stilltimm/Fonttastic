import ProjectDescription

extension TargetReference {

    public static func app() -> TargetReference {
        return TargetReference(projectPath: nil, target: ProjectConstants.appTargetName)
    }

    public static func keyboardExtension() -> TargetReference {
        return TargetReference(projectPath: nil, target: ProjectConstants.keyboardTargetName)
    }

    public static func tools() -> TargetReference {
        return TargetReference(projectPath: nil, target: ProjectConstants.toolsTargetName)
    }
}
