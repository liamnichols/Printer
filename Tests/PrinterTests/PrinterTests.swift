import XCTest
@testable import Printer

final class PrinterTests: XCTestCase {
    func testExamples() {

        // Regular print
        Printer.print("This is a message")

        // Print multiple items
        Printer.print(1, 2, 3)

        // Change the separator
        Printer.print("view", "frame", separator: ".")

        // Extend the terminator
        Printer.print("Hello World", terminator: ".\n")

        // Debug prints
        let object = UIView()
        Printer.print(object)
        Printer.debugPrint(object)

        // TextOutputStream
        dump(object, to: &Printer.streamLogger)

        // String extensions
        UUID().uuidString.write(to: &Printer.streamLogger)
        Printer.print()

        // Close the connection
        Printer.reset()

        // Just gotta do this so that URLSession can finish up...
        sleep(1)
    }

    static var allTests = [
        ("testExamples", testExamples),
    ]
}
