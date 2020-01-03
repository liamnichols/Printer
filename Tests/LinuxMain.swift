import XCTest

import PrinterTests

var tests = [XCTestCaseEntry]()
tests += PrinterTests.allTests()
XCTMain(tests)
