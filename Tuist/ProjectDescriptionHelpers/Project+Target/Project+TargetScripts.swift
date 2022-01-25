import ProjectDescription

extension TargetScript {

    public static func tuistLint() -> TargetScript {
        return .post(script: "tuist lint code", name: "Tuist Lint")
    }
}
