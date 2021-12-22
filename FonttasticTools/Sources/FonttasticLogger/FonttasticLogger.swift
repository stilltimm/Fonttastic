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

    // MARK: - Nested Types

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
        case bugReports
    }

    public struct Config {
        public let enabledOutputs: [LogOutput: Set<LogLevel>]
        public let usesFullDateFormatting: Bool

        public init(
            enabledOutputs: [LogOutput: Set<LogLevel>],
            usesFullDateFormatting: Bool
        ) {
            self.enabledOutputs = enabledOutputs
            self.usesFullDateFormatting = usesFullDateFormatting
        }
    }

    private struct LogMessageContext {
        let level: LogLevel
        let title: String
        let message: String
        let location: String
        let dateString: String
        let error: Error?
    }

    // MARK: - Public Type Properties

    public static let shared = FonttasticLogger()

    // MARK: - Private Type Properties

    private static let compactDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss.SSS"
        return dateFormatter
    }()

    // MARK: - Private Instance Properties

    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared
    private lazy var bugReportsService: BugReportsService = DefaultBugReportsService.shared

    private var config: Config?

    private let loggingQueue: DispatchQueue = DispatchQueue(
        label: "com.romandegtyarev.fonttastic.loggingQueue",
        qos: .default,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Methods

    public func setup(with config: Config) {
        self.config = config
    }

    // MARK: - Private Instance Methods

    private func log(
        level: LogLevel,
        title: String,
        description: String?,
        error: Error?,
        filePath: String,
        line: Int
    ) {
        let logDate = Date()
        loggingQueue.async { [weak self] in
            guard
                let self = self,
                let config = self.config
            else {
                #if DEBUG
                print("Error: please setup logger via FonttasticLogger.setup(with:)")
                #endif

                return
            }

            // make log message
            var message: String = ""
            if let description = description {
                message += "Description: \(description)"
            }
            if let error = error {
                if message.isEmpty {
                    message += "Error: \(error)"
                } else {
                    message += ", Error: \(error)"
                }
            }

            let fileName: String = filePath.split(separator: "/").last.map { String($0)} ?? "undefined"
            let locationString: String = "[File: \(fileName), Line: #\(line)]"

            let dateString: String
            if config.usesFullDateFormatting {
                dateString = Self.fullDateFormatter.string(from: logDate)
            } else {
                dateString = Self.compactDateFormatter.string(from: logDate)
            }

            let logMessageContext = LogMessageContext(
                level: level,
                title: title,
                message: message,
                location: locationString,
                dateString: dateString,
                error: error
            )

            for (logOutput, enabledLogLevels) in config.enabledOutputs {
                guard enabledLogLevels.contains(level) else { continue }
                self.log(logMessageContext, to: logOutput)
            }
        }
    }

    private func log(_ logMessageContext: LogMessageContext, to logOutput: LogOutput) {
        switch logOutput {
        case .console:
            var logString = "\(logMessageContext.level.description)"
            logString += " at \(logMessageContext.location) at \(logMessageContext.dateString)"
            logString += ": \"\(logMessageContext.title)\", message: \"\(logMessageContext.message)\""
            print(logString)

        case .osLog:
            os_log(
                "%@ at %@ at %@: %@, %@",
                log: .default,
                type: logMessageContext.level.asOSLogType,
                logMessageContext.level.description,
                logMessageContext.location,
                logMessageContext.dateString,
                logMessageContext.title,
                logMessageContext.message
            )

        case .analytics:
            guard let analyticsEvent = makeAnalyticsEvent(for: logMessageContext) else { return }
            analyticsService.trackEvent(analyticsEvent)

        case .bugReports:
            if let error = logMessageContext.error {
                bugReportsService.trackError(error: error)
            } else {
                bugReportsService.trackError(
                    error: NonSpecificLogError(
                        title: logMessageContext.title,
                        message: logMessageContext.message,
                        location: logMessageContext.location
                    )
                )
            }
        }
    }

    private func makeAnalyticsEvent(for logMessageContext: LogMessageContext) -> AnalyticsEvent? {
        switch logMessageContext.level {
        case .info:
            return InfoLogAnalyticsEvent(
                title: logMessageContext.title,
                message: logMessageContext.message,
                location: logMessageContext.location,
                dateString: logMessageContext.dateString
            )

        case .error:
            return ErrorLogAnalyticsEvent(
                title: logMessageContext.title,
                message: logMessageContext.message,
                location: logMessageContext.location,
                dateString: logMessageContext.dateString,
                error: logMessageContext.error
            )

        case .debug:
            return nil
        }
    }
}

extension FonttasticLogger {

    public func debug(
        _ title: String,
        description: String?,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.log(
            level: .debug,
            title: title,
            description: description,
            error: nil,
            filePath: filePath,
            line: line
        )
    }
    public func debug(
        _ title: String,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.debug(title, description: nil, filePath: filePath, line: line)
    }

    public func info(
        _ title: String,
        description: String?,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.log(
            level: .info,
            title: title,
            description: description,
            error: nil,
            filePath: filePath,
            line: line
        )
    }
    public func info(
        _ title: String,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.info(title, description: nil, filePath: filePath, line: line)
    }

    public func error(
        _ title: String,
        description: String?,
        error: Error?,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.log(
            level: .error,
            title: title,
            description: description,
            error: error,
            filePath: filePath,
            line: line
        )
    }
    public func error(
        _ title: String,
        error: Error,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.error(title, description: nil, error: error, filePath: filePath, line: line)
    }
    public func error(
        _ title: String,
        description: String,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.error(title, description: description, error: nil, filePath: filePath, line: line)
    }
    public func error(
        _ title: String,
        filePath: String = #file,
        line: Int = #line
    ) {
        self.error(title, description: nil, error: nil, filePath: filePath, line: line)
    }
}

extension FonttasticLogger.Config {

    public static var `default`: FonttasticLogger.Config {
        #if DEBUG
        return FonttasticLogger.Config(
            enabledOutputs: [
                .console: Set(FonttasticLogger.LogLevel.allCases),
                .bugReports: [.error]
            ],
            usesFullDateFormatting: false
        )
        #else
        return FonttasticLogger.Config(
            enabledOutputs: [
                .analytics: [.error, .info],
                .bugReports: [.error]
            ],
            usesFullDateFormatting: true
        )
        #endif
    }
}
