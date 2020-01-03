import Foundation

/// Printer is a simple interface for printing textual messages out to a console via a socket connection
@available(iOS 13.0, *)
public struct Printer {
    /// The port to connect to, defaults to `7529`
    public static var port: Int = 7529

    /// The host to connect to, defaults to `localhost`
    public static var host: String = "localhost"

    /// Resets a stream that might already be open ready to start again the next time that the logger is invoked.
    public static func reset() {
        guard let currentTask = task, case .running = currentTask.state else { return }
        currentTask.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    /// A logger that prints to the open socket stream.
    public static var streamLogger: StreamLogger = {
        let logger = StreamLogger()
        logger.taskProvider = {
            if let task = task { return task }

            var components = URLComponents()
            components.scheme = "ws"
            components.host = host
            components.port = port
            components.path = "/console"
            guard let url = components.url else { return nil }

            let newTask = session.webSocketTask(with: url)
            newTask.resume()

            task = newTask
            return newTask
        }
        return logger
    }()

    /// Similar to `Swift.print(...:separator:terminator:)`, this method will print the items out to the internal stream logger.
    public static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        // https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Print.swift#L217
        _print(items, separator: separator, terminator: terminator, using: String.init(describing:))
    }

    /// Similar to `Swift.debugPrint(...:separator:terminator:)`, this method will print the items out to the internal stream logger in a debuggable format.
    public static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        // https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Print.swift#L234
        _print(items, separator: separator, terminator: terminator, using: String.init(reflecting:))
    }

    private static func _print(_ items: [Any], separator: String, terminator: String, using decorator: (Any) -> String) {
        // Be sure to lock the logger for thread safety
        streamLogger._lock()
        defer { streamLogger._unlock() }

        // Coping the stlib core, loop teh items and write them to the logger
        var prefix = ""
        for item in items {
            prefix.write(to: &streamLogger)
            decorator(item).write(to: &streamLogger)
            prefix = separator
        }
        terminator.write(to: &streamLogger)
    }

    /// The session used for creating web socket connections.
    private static let session = URLSession(configuration: .default)

    /// The session used for sending messages
    private static var task: URLSessionWebSocketTask?
}
