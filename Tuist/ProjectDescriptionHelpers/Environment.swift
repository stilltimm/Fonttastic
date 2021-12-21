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
        guard let environmentValue = getEnvironmentValue() else {
            return Environment()
        }

        return Environment(value: environmentValue)
    }

    private static func getEnvironmentValue() -> [String: String]? {
        let environmentFileURL = URL(fileURLWithPath: "./.Environment")

        do {
            let environmentFileData = try Data(contentsOf: environmentFileURL)
            return try JSONDecoder().decode([String: String].self, from: environmentFileData)
        } catch {
            NSLog("Failed to load Environment from .Environment file, error: %@", "\(error)")
            return nil
        }
    }
}
