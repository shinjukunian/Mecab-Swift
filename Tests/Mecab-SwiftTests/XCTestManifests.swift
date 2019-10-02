import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Mecab_SwiftTests.allTests),
    ]
}
#endif
