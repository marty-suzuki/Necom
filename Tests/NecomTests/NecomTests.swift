import XCTest
@testable import Necom

final class NecomTests: XCTestCase {

    func testExample() {
        struct State: StateType {
            var str: String
        }
        var reference: StateReference<State>!

        XCTContext.runActivity(named: "reference") { _ in
            let expected = "test"
            reference = StateReference(State(str: expected))
            XCTAssertEqual(reference.str, expected)
        }

        XCTContext.runActivity(named: "mutating") { _ in
            let expected = "test"
            let unexpected = ""
            reference = StateReference(State(str: unexpected))
            XCTAssertEqual(reference.str, unexpected)
            
            reference.proxy.str = expected
            XCTAssertEqual(reference.str, expected)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
