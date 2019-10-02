import XCTest
@testable import Mecab_Swift

final class Mecab_SwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Mecab_Swift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
