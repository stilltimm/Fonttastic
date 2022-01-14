import Foundation
import ProjectDescription

public struct Environment {

    // MARK: - Public Instance Properties

    public let value: [String: String]

    // MARK: - Initializers

    public init(value: [String: String]) {
        self.value = value
    }

    public init() {
        self.value = [:]
    }
}

extension Environment {

    // MARK: - Public Type Methods

    public static func `default`() -> Environment {
        return Environment(value: [:])
    }
}
