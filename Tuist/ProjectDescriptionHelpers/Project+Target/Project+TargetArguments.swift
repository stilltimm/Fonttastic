import ProjectDescription

extension Arguments {

    public static func `default`() -> Arguments {
        return Arguments(
            environment: Environment.default().value,
            launchArguments: []
        )
    }
}
