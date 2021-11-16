//
//  FonttasticLogger.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import OSLog

public let logger: FonttasticLogger = FonttasticLogger.shared

public class FonttasticLogger {

    public enum LogLevel: UInt8, CaseIterable {

        case info
        case debug
        case error

        public var description: String {
            switch self {
            case .info:
                return "ℹ️ INFO"

            case .debug:
                return "🛠 DEBUG"

            case .error:
                return "⛔️ ERROR"
            }
        }

        fileprivate var asOSLogType: OSLogType {
            switch self {
            case .info:
                return .info

            case .debug:
                return .debug

            case .error:
                return .error
            }
        }
    }

    public enum LogOutput: UInt8 {

        case console
        case osLog
        case analytics
    }

    public struct Config {
        public let enabledOutputs: [LogOutput: Set<LogLevel>]

        public init(enabledOutputs: [LogOutput: Set<LogLevel>]) {
            self.enabledOutputs = enabledOutputs
        }
    }

    private struct LogMessageContext {
        let level: LogLevel
        let logMessage: String
        let locationString: String
        let dateString: String
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()

    public static let shared = FonttasticLogger()

    private var config: Config?

    private init() {}

    public func setup(with config: Config) {
        self.config = config
    }

    public func log(
        _ title: String,
        level: LogLevel,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.log(title, description: nil, level: level, filePath: filePath, line: line)
    }

    public func log(
        _ title: String,
        description: String?,
        level: LogLevel,
        filePath: String = #file,
        line: Int = #line
    ) {
        guard let config = config else {
            print("Error: please setup logger via FonttasticLogger.setup(with:)")
            return
        }

        var logMessage: String = "\(title)"
        if let description = description {
            logMessage += "\n\(description)"
        }
        let fileName: String = filePath.split(separator: "/").last.map { String($0)} ?? "undefined"
        let dateString = Self.dateFormatter.string(from: Date())

        let logMessageContext = LogMessageContext(
            level: level,
            logMessage: logMessage,
            locationString: "[File: \"\(fileName)\", Line: #\(line)]",
            dateString: "[Time: \(dateString)]"
        )

        for (logOutput, enabledLogLevels) in config.enabledOutputs {
            guard enabledLogLevels.contains(level) else { continue }
            log(logMessageContext, to: logOutput)
        }
    }

    private func log(_ logMessageContext: LogMessageContext, to logOutput: LogOutput) {
        switch logOutput {
        case .console:
            let levelDescription = logMessageContext.level.description
            let locationString = logMessageContext.locationString
            let dateString = logMessageContext.dateString
            print("\(levelDescription) at \(locationString) at \(dateString): \(logMessageContext.logMessage)")

        case .osLog:
            os_log(
                "at %@ at %@: %@",
                log: .default,
                type: logMessageContext.level.asOSLogType,
                logMessageContext.locationString,
                logMessageContext.dateString,
                logMessageContext.logMessage
            )

        case .analytics:
            print("TODO: Implement logging to Analytics")

        }
    }
}

extension FonttasticLogger.Config {

    public static var `default`: FonttasticLogger.Config {
        #if DEBUG
        return FonttasticLogger.Config(
            enabledOutputs: [
                .console: Set(FonttasticLogger.LogLevel.allCases)
            ]
        )
        #elseif BETA
        return FonttasticLogger.Config(
            enabledOutputs: [
                .osLog: [.error, .info]
            ]
        )
        #else
        return FonttasticLogger.Config(
            enabledOutputs: [
                .analytics: [.error]
            ]
        )
        #endif
    }
}
