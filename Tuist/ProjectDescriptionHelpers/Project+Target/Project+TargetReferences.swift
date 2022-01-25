import ProjectDescription

extension TargetReference {

    public static func app() -> TargetReference {
        return TargetReference(projectPath: nil, target: "Fonttastic")
    }

    public static func keyboardExtension() -> TargetReference {
        return TargetReference(projectPath: nil, target: "FonttasticKeyboard")
    }

    public static func tools() -> TargetReference {
        return TargetReference(projectPath: nil, target: "FonttasticTools")
    }
}
