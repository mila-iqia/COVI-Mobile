
import Foundation

import os.log


public struct Logger {

    /// An identifier of the creator of this `Logger`.
    public let label: String

    internal init(label: String) {
        self.label = label
    }
}

extension Logger {
    /// Log a message passing the log level as a parameter.
    ///
    /// If the `logLevel` passed to this method is more severe than `error`, it will be logged all the time,
    /// otherwise, if not building against DEBUG, nothing will happen.
    ///
    /// - parameters:
    ///    - level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func log(level: Logger.Level,
                    _ message: String,
                    metadata: String = "",
                    file: String = #file, function: String = #function, line: UInt = #line) {
        var toLog : String = "[\(self.label) - \(level.label) \(level.icon)] "
        
        // Load message
        toLog += "\(message)"
        
        // If Metadata was provided, add it
        if (metadata != "") {
            toLog += "\nMetadata: \(metadata)"
        }
        
        // Load metadata automatically collected about the code if on debug
        #if DEBUG
        toLog += "\nFile: \(file) | Line: \(line) | Function: \(function)"
        #endif
        
        #if DEBUG || PROFILE
            os_log("%@", type: level.os_logLevel, toLog)
        #else
            if (level > .error) {
                os_log("%@", type: level.os_logLevel, toLog)
            }
        #endif
    }
}



extension Logger {
    /// Log a message passing with the `Logger.Level.trace` log level.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func trace(_ message: String,
                      metadata: String = "",
                      file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .trace, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.debug` log level.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func debug(_ message: String,
                      metadata: String = "",
                      file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .debug, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.info` log level.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func info(_ message: String,
                     metadata: String = "",
                     file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .info, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.notice` log level.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func notice(_ message: String,
                       metadata: String = "",
                       file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .notice, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.warning` log level.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func warning(_ message: String,
                        metadata: String = "",
                        file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .warning, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.error` log level.
    ///
    /// `.error` message will always be logged
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func error(_ message: String,
                      metadata: String = "",
                      file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .error, message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Log a message passing with the `Logger.Level.critical` log level.
    ///
    /// `.critical` messages will always be logged.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#file`).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func critical(_ message: String,
                         metadata: String = "",
                         file: String = #file, function: String = #function, line: UInt = #line) {
        self.log(level: .critical, message, metadata: metadata, file: file, function: function, line: line)
    }
}

extension Logger {
    /// The log level.
    ///
    /// Log levels are ordered by their severity, with `.trace` being the least severe and
    /// `.critical` being the most severe.
    public enum Level: String, Codable, CaseIterable {
       /// Appropriate for messages that contain information only when debugging a program.
       case trace

       /// Appropriate for messages that contain information normally of use only when
       /// debugging a program.
       case debug

       /// Appropriate for informational messages.
       case info

       /// Appropriate for conditions that are not error conditions, but that may require
       /// special handling.
       case notice

       /// Appropriate for messages that are not error conditions, but more severe than
       /// `.notice`.
       case warning

       /// Appropriate for error conditions.
       case error

       /// Appropriate for critical error conditions that usually require immediate
       /// attention.
       ///
       /// When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
       /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
       /// debugging.
       case critical
    }
}
extension Logger.Level {
    internal var naturalIntegralValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .warning:
            return 4
        case .error:
            return 5
        case .critical:
            return 6
        }
    }
    
    public var os_logLevel: OSLogType {
        switch self {
        case .trace:
            return OSLogType.info
        case .debug:
            return OSLogType.debug
        case .info:
            return OSLogType.info
        case .notice:
            return OSLogType.info
        case .warning:
            return OSLogType.debug
        case .error:
            return OSLogType.error
        case .critical:
            return OSLogType.fault
        }
    }
    
    public var icon: String {
        switch self {
        case .trace:
            return "📑"
        case .debug:
            return "🐛"
        case .info:
            return "💡"
        case .notice:
            return "✳️"
        case .warning:
            return "⚠️"
        case .error:
            return "⛔"
        case .critical:
            return "☠️"
        }
    }
    
    public var label: String {
        switch self {
        case .trace:
            return "Trace"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .critical:
            return "Critical"
        }
    }
}

extension Logger.Level: Comparable {
    public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
        return lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}
