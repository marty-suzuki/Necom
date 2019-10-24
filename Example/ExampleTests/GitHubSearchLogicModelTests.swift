//
//  GitHubSearchLogicModelTests.swift
//  ExampleTests
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom
import XCTest
@testable import Example

class GitHubSearchLogicModelTests: XCTestCase {

    private var debounce: MockDebounce!
    private var testTarget: GitHubSearchLogicModel!
    private var delegateProxy: DelegateProxy<GitHubSearchAPIModelDelegate>!
    private var delegate: MockGitHubSearchLogicModelDelegate!
    private var searchAPIModel: MockGitHubSearchAPIModel!

    override func setUp() {
        self.debounce = MockDebounce()
        self.searchAPIModel = MockGitHubSearchAPIModel()
        self.delegate = MockGitHubSearchLogicModelDelegate()
        self.testTarget = GitHubSearchLogicModel(extra: .init(searchAPIModel: searchAPIModel,
                                                              debounce: debounce))
        testTarget.connect(delegate)
        self.delegateProxy = searchAPIModel.delegate
    }

    func test_query_is_not_empty() {
        let query = "search query"
        testTarget.action.searchText(query)
        XCTAssertEqual(searchAPIModel.query, query)
        XCTAssertEqual(searchAPIModel.calledCount, 1)
    }

    func test_query_is_empty() {
        let query = ""
        testTarget.action.searchText(query)
        XCTAssertNil(searchAPIModel.query)
        XCTAssertEqual(searchAPIModel.calledCount, 0)
    }

    func test_searchResponse() {
        let expected = [GitHub.Repository.mock]
        delegateProxy.searchResponse(GitHub.ItemsResponse(items: expected))
        XCTAssertEqual(delegate._repositories, expected)
    }

    func test_searchError() {
        delegateProxy.searchError(MockError())
        XCTAssertTrue(delegate._error is MockError)
    }
}

extension GitHubSearchLogicModelTests {

    private struct MockDebounce: DebounceType {
        func execute(_ handler: @escaping () -> Void) {
            handler()
        }
    }

    private final class MockGitHubSearchAPIModel: GitHubSearchAPIModelType {
        private(set) lazy var action: ActionProxy<GitHubSearchAPIModel.Action> = undefined()
        private(set) var delegate: DelegateProxy<GitHubSearchAPIModelDelegate>?

        private(set) var query: String?
        private(set) var calledCount = 0

        init() {
            self.action = ActionProxy(.init(searchRepository: { [weak self] in
                self?.query = $0
                self?.calledCount += 1
            }))
        }

        func connect(_ delegate: GitHubSearchAPIModelDelegate) {
            self.delegate = DelegateProxy(delegate: delegate)
        }
    }

    private final class MockGitHubSearchLogicModelDelegate: GitHubSearchLogicModelDelegate {

        private(set) var _repositories: [GitHub.Repository]?
        private(set) var _error: Error?

        var repositories: Binder<[GitHub.Repository]> {
            Binder(self, \._repositories)
        }

        var error: Binder<Error> {
            Binder(self, \._error)
        }
    }
}
