import ProjectDescription

extension DeploymentTarget {

    public static func iOS_14_iphone() -> DeploymentTarget {
        return .iOS(targetVersion: "14.0", devices: .iphone)
    }
}
