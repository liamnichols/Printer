import Foundation

@available(iOS 13.0, *)
public class StreamLogger: TextOutputStream {
    internal var taskProvider: (() -> URLSessionWebSocketTask?)?

    public func write(_ string: String) {
        guard let task = taskProvider?() else { return }

        // TODO: Buffer the output... 
        task.send(.string(string), completionHandler: { _ in })
    }
}
